local async = require 'utils.async'
local files = require 'buffer.files.helpers'

---@alias Picker.Step fun(previous: any): any

---@class Picker.Source
---@field prompt? string
---@field cwd? string
---@field items? any[]
---@field format? fun(item: any): string
---@field display? fun(item: any): string, table
---@field should_keep_order? boolean
---@field steps? Picker.Step[]

---@class Picker
---@field find fun(self: Picker, source?: Picker.Source|string): any
---@field grep fun(self: Picker, source?: Picker.Source|string): string|nil
---@field readonly fun(self: Picker, target: Picker.Source|string): string|nil
---@field on_prompt_close fun(prompt_bufnr: integer, callback: fun())
local M = {}

---@param fn async fun(argument: any): any
---@return function
local function entry_point(fn)
  return function(receiver, argument)
    if receiver ~= M then argument = receiver end
    if async.current_coroutine() then return fn(argument) end
    async.run(fn, argument)
  end
end

---@param prompt_bufnr integer
---@param callback fun()
function M.on_prompt_close(prompt_bufnr, callback)
  vim.api.nvim_create_autocmd('BufWipeout', {
    buffer = prompt_bufnr,
    once = true,
    callback = function() vim.schedule(callback) end,
  })
end

---@param source Picker.Source
---@return any[]
local function prepare_items(source)
  local items = vim.list_extend({}, source.items)
  if not source.should_keep_order then table.sort(items) end
  return items
end

---@param source Picker.Source
---@param item any
---@return table
local function create_entry(source, item)
  local label = (source.format or tostring)(item)
  local display = source.display and function() return source.display(item) end
    or label
  return { value = item, display = display, ordinal = label }
end

---@async
---@param source Picker.Source
---@return any item
local function pick_item(source)
  local prompt = source.prompt or 'Select'
  if #source.items == 0 then
    vim.notify.warn(('No items found for %s'):format(prompt))
    return nil
  end

  local items = prepare_items(source)
  return async.await(function(resolve)
    local actions = require 'telescope.actions'
    local item_picker = require('telescope.pickers').new({}, {
      prompt_title = prompt,
      finder = require('telescope.finders').new_table {
        results = items,
        entry_maker = function(item) return create_entry(source, item) end,
      },
      sorter = require('telescope.config').values.generic_sorter {},
      attach_mappings = function(prompt_bufnr)
        M.on_prompt_close(prompt_bufnr, resolve)
        actions.select_default:replace(function()
          local entry = require('telescope.actions.state').get_selected_entry()
          if not entry then return end
          actions.close(prompt_bufnr)
          resolve(entry.value)
        end)
        return true
      end,
    })
    item_picker:find()
  end)
end

---@async
---@param builtin 'find_files'|'live_grep'
---@param source Picker.Source
---@return string|nil path
local function pick_file(builtin, source)
  return async.await(function(resolve)
    require('telescope.builtin')[builtin] {
      cwd = source.cwd,
      prompt_title = source.prompt,
      attach_mappings = function(prompt_bufnr)
        M.on_prompt_close(prompt_bufnr, resolve)
        require('telescope.actions.set').select:enhance {
          post = function()
            local bufnr = vim.api.nvim_get_current_buf()
            if bufnr == prompt_bufnr then return end
            resolve(vim.api.nvim_buf_get_name(bufnr))
          end,
        }
        return true
      end,
    }
  end)
end

---@param source Picker.Source|string|nil
---@return Picker.Source
local function to_source(source)
  if type(source) == 'string' then return { cwd = source } end
  return source or {}
end

---@async
---@param selection any
---@param steps Picker.Step[]|nil
---@return any
local function run_steps(selection, steps)
  for _, step in ipairs(steps or {}) do
    if selection == nil then return nil end
    selection = step(selection)
  end
  return selection
end

---@async
---@param source Picker.Source|string|nil
---@return any selection
local function find(source)
  source = to_source(source)
  if source.items then return run_steps(pick_item(source), source.steps) end
  return run_steps(pick_file('find_files', source), source.steps)
end

---@async
---@param source Picker.Source|string|nil
---@return string|nil path
local function grep(source)
  source = to_source(source)
  return run_steps(pick_file('live_grep', source), source.steps)
end

---@async
---@param target Picker.Source|string
---@return string|nil path
local function readonly(target)
  local path = target
  if type(target) == 'table' then path = find(target) end
  if not path then return nil end

  if vim.api.nvim_buf_get_name(0) ~= path then files.open_file(path) end
  files.mark_buffer_as_readonly(vim.api.nvim_get_current_buf())
  return path
end

M.find = entry_point(find)
M.grep = entry_point(grep)
M.readonly = entry_point(readonly)

return M
