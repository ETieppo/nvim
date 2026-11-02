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

---@param name string
---@return boolean
local function is_lua_file(name) return name:sub(-4) == '.lua' end

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
    elseif is_lua_file(name) then
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

---@param dir string
---@return string[]
function M.find_lua_module_names(dir)
  local names = {}
  for name, entry_type in vim.fs.dir(dir) do
    if entry_type == 'file' and is_lua_file(name) and name ~= 'init.lua' then
      table.insert(names, name:sub(1, -5))
    end
  end
  table.sort(names)
  return names
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
