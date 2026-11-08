---@class FindModulesOptionsProps
---@field exclude? table<string, boolean>

---@class LazyImportProps
---@field import string

---@class CommandProps
---@field short string
---@field run fun(param: any|nil)

---@class NamedEntryProps
---@field short? string

local M = {}

---@param stack_level integer
---@return string
local function get_filename_at_stack_level(stack_level)
  local source = debug.getinfo(stack_level + 1, 'S').source
  local filename = vim.fn.fnamemodify(source:sub(2), ':t:r')
  return filename
end

---@return string
function M.get_this_filename()
  local filename = get_filename_at_stack_level(2)
  return filename
end

---@return string
function M.get_caller_filename()
  local filename = get_filename_at_stack_level(3)
  return filename
end

---@generic T : NamedEntryProps
---@param entries table<string, T>
---@param name_or_short string
---@return T|nil
function M.find_by_name_or_short(entries, name_or_short)
  if entries[name_or_short] then return entries[name_or_short] end

  for _, entry in pairs(entries) do
    if entry.short == name_or_short then return entry end
  end

  return nil
end

---@param mode string|string[]
---@param alt_key string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.set_alt_and_cmd_keymap(mode, alt_key, rhs, opts)
  local keymap_opts = vim.tbl_extend('force', { silent = true }, opts or {})
  local cmd_key = alt_key:gsub('<M%-', '<D-')

  vim.keymap.set(mode, alt_key, rhs, keymap_opts)
  if cmd_key ~= alt_key then vim.keymap.set(mode, cmd_key, rhs, keymap_opts) end
end

---@generic T
---@param value T|T[]
---@return T[]
function M.ensure_list(value)
  if type(value) == 'table' then return value end
  return { value }
end

return M
