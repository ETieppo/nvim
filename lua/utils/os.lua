local M = {}

local sysname = vim.uv.os_uname().sysname
local os_name = sysname == 'Darwin' and 'macos'
  or sysname == 'Linux' and 'linux'
  or sysname:find 'Windows' and 'win32'
  or nil

local sep = package.config:sub(1, 1)
local resolved = {}
local pm_cache = nil

function M.get_name() return os_name end
function M.is_macos() return os_name == 'macos' end
function M.is_linux() return os_name == 'linux' end
function M.is_windows() return os_name == 'win32' end

function M.rewrite_to_os_path(path) return (path:gsub('[/\\]', sep)) end
function M.normalize_os_path(path) return (path:gsub('\\', '/')) end

---@param name string
---@return string|nil
function M.which(name)
  local cached = resolved[name]
  if cached ~= nil then return cached or nil end

  local path = vim.fn.exepath(name)
  if path == '' and M.is_macos() and vim.fn.executable 'xcrun' == 1 then
    local found = vim
      .system({ 'xcrun', '--find', name }, { text = true })
      :wait()
    if found.code == 0 then path = vim.trim(found.stdout or '') end
  end
  if path == '' or vim.fn.executable(path) ~= 1 then path = nil end

  resolved[name] = path or false
  return path
end

function M.has_deps(name) return M.which(name) ~= nil end
function M.forget()
  resolved, pm_cache = {}, nil
end

function M.bootstrap_scoop()
  if not M.is_windows() or M.has_deps 'scoop' then return end
  M.run_in_terminal {
    'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
    'irm get.scoop.sh | iex',
  }
end

function M.get_package_manager()
  if pm_cache ~= nil then return pm_cache or nil end

  local pm
  if M.is_macos() then
    pm = M.has_deps 'brew' and 'brew' or nil
  elseif M.is_windows() then
    pm = M.has_deps 'scoop' and 'scoop' or M.bootstrap_scoop() and 'scoop'
  elseif M.is_linux() then
    for _, p in ipairs { 'pacman', 'apt', 'dnf', 'zypper', 'apk' } do
      if M.has_deps(p) then
        pm = p
        break
      end
    end
  end

  pm_cache = pm or false
  return pm
end

local function is_installed(dep)
  if dep.check then return dep.check() end
  return dep.bin ~= nil and M.has_deps(dep.bin)
end

function M.missing(deps)
  return vim.tbl_filter(function(dep) return not is_installed(dep) end, deps)
end

local function install_cmd(dep)
  local override = dep.os_override and dep.os_override[os_name]
  if override then return override end

  local pm = M.get_package_manager()
  local args = pm and dep.install and dep.install[pm]
  if not args then return dep.fallback end

  local no_sudo = { yay = true, paru = true }
  local cmd = (M.is_linux() and not no_sudo[pm]) and { 'sudo', pm } or { pm }
  return vim.list_extend(cmd, args)
end

function M.get_os_joiner() return M.is_windows() and ' ; ' or ' && ' end

---@param cmds string[]
function M.run_in_terminal(cmds)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].filetype == 'snacks_dashboard'
    then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end

  vim.cmd.tabnew()
  vim.cmd.terminal(table.concat(cmds, M.get_os_joiner()))
  vim.cmd.startinsert()
end

---@param deps table[]
function M.install(deps)
  local missing = M.missing(deps)
  if #missing == 0 then
    return vim.notify('All dependencies installed.', vim.log.levels.INFO)
  end

  local cmds, skipped = {}, {}
  for _, dep in ipairs(missing) do
    local cmd = install_cmd(dep)
    if cmd then
      table.insert(cmds, table.concat(cmd, ' '))
    else
      table.insert(skipped, dep.name)
    end
  end

  if #skipped > 0 then
    vim.notify(
      'No install command (manual intervention needed): '
        .. table.concat(skipped, ', '),
      vim.log.levels.WARN
    )
  end

  if #cmds == 0 then return end
  M.forget()
  M.run_in_terminal(cmds)
end

return M
