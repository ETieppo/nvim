local M = {}
local os = require 'utils.os'

local deps = {
  {
    name = 'git',
    bin = 'git',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'git' },
      apt = { 'install', '-y', 'git' },
      dnf = { 'install', '-y', 'git' },
      zypper = { 'install', '-y', 'git' },
      apk = { 'add', 'git' },
      brew = { 'install', 'git' },
      scoop = { 'install', 'git' },
    },
  },
  {
    name = 'ripgrep (rg)',
    bin = 'rg',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'ripgrep' },
      apt = { 'install', '-y', 'ripgrep' },
      dnf = { 'install', '-y', 'ripgrep' },
      zypper = { 'install', '-y', 'ripgrep' },
      apk = { 'add', 'ripgrep' },
      brew = { 'install', 'ripgrep' },
      scoop = { 'install', 'ripgrep' },
    },
  },
  {
    name = 'fd',
    bin = 'fd',
    required = false,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'fd' },
      apt = { 'install', '-y', 'fd-find' },
      dnf = { 'install', '-y', 'fd-find' },
      zypper = { 'install', '-y', 'fd' },
      apk = { 'add', 'fd' },
      brew = { 'install', 'fd' },
      scoop = { 'install', 'fd' },
    },
  },
  {
    name = 'C compiler',
    required = true,
    check = function()
      return vim.fn.executable 'cc' == 1
        or vim.fn.executable 'gcc' == 1
        or vim.fn.executable 'clang' == 1
    end,
    os_override = { mac = { 'xcode-select', '--install' } },
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'gcc' },
      apt = { 'install', '-y', 'build-essential' },
      dnf = { 'install', '-y', 'gcc' },
      zypper = { 'install', '-y', 'gcc' },
      apk = { 'add', 'build-base' },
      scoop = { 'install', 'gcc' },
    },
  },
  {
    name = 'tree-sitter-cli',
    bin = 'tree-sitter',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'tree-sitter-cli' },
      dnf = { 'install', '-y', 'tree-sitter-cli' },
      brew = { 'install', 'tree-sitter' },
      scoop = { 'install', 'tree-sitter' },
    },
    fallback = { 'cargo', 'install', 'tree-sitter-cli' },
  },
}

local function is_installed(dep)
  if dep.check then return dep.check() end
  return dep.bin ~= nil and vim.fn.executable(dep.bin) == 1
end

function M.missing()
  local out = {}
  for _, dep in ipairs(deps) do
    if not is_installed(dep) then table.insert(out, dep) end
  end
  return out
end

local function install_cmd(dep)
  local os_name = os.get_name()
  local pm = os.get_package_manager()
  if dep.os_override and dep.os_override[os_name] then
    return dep.os_override[os_name]
  end
  local args = dep.install and pm and dep.install[pm]
  if args then
    local cmd = os.is_linux() and { 'sudo', pm } or { pm }
    vim.list_extend(cmd, args)
    return cmd
  end
  return dep.fallback
end

function M.install()
  local missing = M.missing()
  if #missing == 0 then
    vim.notify('All dependencies installed.', vim.log.levels.INFO)
    return
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
      'No install command (need manual intervension): '
        .. table.concat(skipped, ', '),
      vim.log.levels.WARN
    )
  end
  if #cmds == 0 then return end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].filetype == 'snacks_dashboard'
    then
      pcall(vim.api.nvim_buf_delete, b, { force = true })
    end
  end
  vim.cmd 'tabnew'
  vim.cmd('terminal ' .. table.concat(cmds, ' && '))
  vim.cmd 'startinsert'
end

return M
