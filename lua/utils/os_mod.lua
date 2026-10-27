local OsNameEnum = require 'utils.enums.os_name_enum'

local M = {}

local sysname = vim.uv.os_uname().sysname

---@type OsNameEnum|nil
local os_name = sysname == 'Darwin' and OsNameEnum.macos
  or sysname == 'Linux' and OsNameEnum.linux
  or sysname:find 'Windows' and OsNameEnum.windows
  or nil

local path_separator = package.config:sub(1, 1)
local path_list_separator = os_name == OsNameEnum.windows and ';' or ':'

---@type table<string, string|false>
local resolved_executables = {}

---@return OsNameEnum|nil
function M.get_name() return os_name end

---@return boolean
function M.is_macos() return os_name == OsNameEnum.macos end

---@return boolean
function M.is_windows() return os_name == OsNameEnum.windows end

---@param path string
---@return string
function M.rewrite_to_os_path(path) return (path:gsub('[/\\]', path_separator)) end

---@param path string
---@return string
function M.normalize_os_path(path) return (path:gsub('\\', '/')) end

---@param path string
---@return string|nil
function M.get_home_relative_path(path)
  local relative = path:match '^~[/\\](.*)$'
  if relative then return relative end
  if vim.fn.isabsolutepath(path) == 1 then return nil end
  return (path:gsub('^%.[/\\]', ''))
end

---@param path string
---@return string
function M.expand_home_path(path)
  local relative = M.get_home_relative_path(path)
  if not relative then return path end
  return vim.fs.joinpath(vim.uv.os_homedir() or '', relative)
end

---@param name string
---@return string|nil
local function find_executable_path(name)
  local path = vim.fn.exepath(name)

  if path == '' and M.is_macos() and vim.fn.executable 'xcrun' == 1 then
    local result = vim
      .system({ 'xcrun', '--find', name }, { text = true })
      :wait()
    if result.code == 0 then path = vim.trim(result.stdout or '') end
  end

  if path == '' or vim.fn.executable(path) ~= 1 then return nil end
  return path
end

---@param name string
---@return string|nil
function M.which(name)
  local cached = resolved_executables[name]
  if cached ~= nil then return cached or nil end

  local path = find_executable_path(name)
  resolved_executables[name] = path or false
  return path
end

---@param name string
---@return boolean
function M.has_executable(name) return M.which(name) ~= nil end

function M.clear_cache() resolved_executables = {} end

---@param dir string
---@return boolean
function M.add_to_path(dir)
  if vim.fn.isdirectory(dir) == 0 then return false end

  local current_path = vim.env.PATH or ''
  local entries = vim.split(current_path, path_list_separator, { plain = true })
  if vim.list_contains(entries, dir) then return false end

  vim.env.PATH = current_path == '' and dir
    or dir .. path_list_separator .. current_path
  M.clear_cache()
  return true
end

---@param command string
---@return string|nil
function M.read_command_output(command)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then return nil end
  return output
end

return M
