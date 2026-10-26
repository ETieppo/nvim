local OsNameEnum = require 'utils.enums.os_name_enum'
local package_managers = require 'utils.package_managers'

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

---@type PackageManager|false|nil
local cached_package_manager = nil

---@return OsNameEnum|nil
function M.get_name() return os_name end

---@return boolean
function M.is_macos() return os_name == OsNameEnum.macos end

---@return boolean
function M.is_linux() return os_name == OsNameEnum.linux end

---@return boolean
function M.is_windows() return os_name == OsNameEnum.windows end

---@param path string
---@return string
function M.rewrite_to_os_path(path) return (path:gsub('[/\\]', path_separator)) end

---@param path string
---@return string
function M.normalize_os_path(path) return (path:gsub('\\', '/')) end

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

function M.clear_cache()
  resolved_executables = {}
  cached_package_manager = nil
end

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

---@return PackageManager|nil
function M.get_package_manager()
  if cached_package_manager == nil then
    cached_package_manager = package_managers.detect(os_name, M.has_executable)
      or false
  end
  return cached_package_manager or nil
end

---@param command string
---@return string|nil
function M.read_command_output(command)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then return nil end
  return output
end

---@param commands string[]
---@param target_os_name? OsNameEnum
---@return string
function M.join_commands(commands, target_os_name)
  if (target_os_name or os_name) == OsNameEnum.windows then
    return table.concat(commands, ' ; ')
  end

  local grouped = vim.tbl_map(
    function(command) return '{ ' .. command .. '; }' end,
    commands
  )
  return table.concat(grouped, ' && ')
end

---@param script string
---@return string[]
local function build_shell_argv(script)
  if not M.is_windows() then return { vim.o.shell, '-c', script } end

  local powershell = M.has_executable 'pwsh' and 'pwsh' or 'powershell'
  return {
    powershell,
    '-NoLogo',
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    script,
  }
end

local function close_dashboard_buffers()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buffer)
      and vim.bo[buffer].filetype == 'snacks_dashboard'
    then
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
  end
end

---@param commands string[]
function M.run_in_terminal(commands)
  close_dashboard_buffers()
  vim.cmd.tabnew()
  vim.fn.jobstart(build_shell_argv(M.join_commands(commands)), {
    term = true,
    on_exit = function() M.clear_cache() end,
  })
  vim.cmd.startinsert()
end

return M
