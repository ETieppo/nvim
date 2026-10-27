---@class FindModulesOptionsProps
---@field exclude? table<string, boolean>

---@class LazyImportProps
---@field import string

---@class CommandProps
---@field short string
---@field run fun(param: any|nil)

local M = {}

---@param dir string
---@param prefix string
---@param opts FindModulesOptionsProps
---@return LazyImportProps[]
local function scan_imported_modules(dir, prefix, opts)
  local exclude = opts.exclude or {}
  local imports, subdirs = {}, {}
  local has_lua_file = false
  local handle = vim.uv.fs_scandir(dir)

  if not handle then return imports end

  while true do
    local name, entry_type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if entry_type == 'directory' then
      table.insert(subdirs, name)
    elseif name:sub(-4) == '.lua' then
      has_lua_file = true
    end
  end

  if has_lua_file then table.insert(imports, { import = prefix }) end

  for _, name in ipairs(subdirs) do
    local module = prefix .. '.' .. name
    if not exclude[module] then
      vim.list_extend(
        imports,
        scan_imported_modules(dir .. '/' .. name, module, opts)
      )
    end
  end

  return imports
end

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

---@param base_dir string
---@param prefix string
---@param opts? FindModulesOptionsProps
---@return LazyImportProps[]
function M.find_modules(base_dir, prefix, opts)
  local dir = vim.fn.stdpath 'config' .. base_dir
  return scan_imported_modules(dir, prefix, opts or {})
end

---@param list CommandProps[]
---@param name_or_short string
---@return CommandProps|nil
function M.find_command_in(list, name_or_short)
  if list[name_or_short] then return list[name_or_short] end

  for _, command in pairs(list) do
    if command.short == name_or_short then return command end
  end

  return nil
end

return M
