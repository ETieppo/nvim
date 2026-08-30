local M = {}

local function os_name()
  if vim.fn.has 'mac' == 1 then return 'mac' end
  if vim.fn.has 'win32' == 1 then return 'windows' end
  return 'linux'
end

local function pm_for(os)
  if os == 'mac' then return vim.fn.executable 'brew' == 1 and 'brew' or nil end
  local list = (os == 'windows') and { 'winget', 'scoop', 'choco' }
    or { 'pacman', 'apt', 'dnf', 'zypper', 'apk' }
  for _, pm in ipairs(list) do
    if vim.fn.executable(pm) == 1 then return pm end
  end
  return nil
end

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
      winget = { 'install', '-e', '--id', 'Git.Git' },
      scoop = { 'install', 'git' },
      choco = { 'install', '-y', 'git' },
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
      winget = { 'install', '-e', '--id', 'BurntSushi.ripgrep.MSVC' },
      scoop = { 'install', 'ripgrep' },
      choco = { 'install', '-y', 'ripgrep' },
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
      winget = { 'install', '-e', '--id', 'sharkdp.fd' },
      scoop = { 'install', 'fd' },
      choco = { 'install', '-y', 'fd' },
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
      winget = { 'install', '-e', '--id', 'MSYS2.MSYS2' },
      scoop = { 'install', 'gcc' },
      choco = { 'install', '-y', 'mingw' },
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

local function install_cmd(dep, os, pm)
  if dep.os_override and dep.os_override[os] then return dep.os_override[os] end
  local args = dep.install and pm and dep.install[pm]
  if args then
    local cmd = (os == 'linux') and { 'sudo', pm } or { pm }
    vim.list_extend(cmd, args)
    return cmd
  end
  return dep.fallback
end

function M.install()
  local os, pm = os_name(), pm_for(os_name())
  local missing = M.missing()
  if #missing == 0 then
    vim.notify('All dependencies installed.', vim.log.levels.INFO)
    return
  end
  local cmds, skipped = {}, {}
  for _, dep in ipairs(missing) do
    local cmd = install_cmd(dep, os, pm)
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
  vim.cmd('botright split | terminal ' .. table.concat(cmds, ' && '))
end

return M
