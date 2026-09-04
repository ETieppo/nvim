local M = {}

function M.rewrite_to_os_path(path)
  local sep = package.config:sub(1, 1)
  return (path:gsub('[/\\]', sep))
end

function M.normalize_os_path(path) return (path:gsub('\\', '/')) end
function M.has_deps(dep_name) return vim.fn.executable(dep_name) == 1 end
function M.is_unix() return vim.fn.has 'macunix' == 1 end
function M.is_windows() return vim.fn.has 'win32' == 1 end
function M.is_linux() return vim.fn.has 'linux' == 1 end
function M.is_macos() return vim.fn.has 'mac' == 1 end
function M.get_name()
  if M.is_macos() then return 'macos' end
  if M.is_linux() then return 'linux' end
  if M.is_windows() then return 'win32' end
end

function M.get_package_manager()
  if M.is_macos() then
    return vim.fn.executable 'brew' == 1 and 'brew' or nil
  end
  if M.is_windows then
    if vim.fn.executable 'scoop' == 0 then
      vim.cmd 'tabnew'
      vim.cmd 'terminal Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force'
      vim.cmd 'terminal irm get.scoop.sh | iex'
      vim.cmd 'startinsert'
    end
    return 'scoop'
  end
  if M.is_linux then
    for _, pm in ipairs { 'pacman', 'apt', 'dnf', 'zypper', 'apk' } do
      if vim.fn.executable(pm) == 1 then return pm end
    end
    return nil
  end
end

return M
