local M = {}

---@enum OsNameEnum
M.OsNameEnum = {
  macos = 'macos',
  linux = 'linux',
  windows = 'windows',
}

---@enum PackageManagerNameEnum
M.PackageManagerNameEnum = {
  pacman = 'pacman',
  yay = 'yay',
  apt = 'apt',
  dnf = 'dnf',
  zypper = 'zypper',
  apk = 'apk',
  brew = 'brew',
  scoop = 'scoop',
}

---@enum ShellNameEnum
M.ShellNameEnum = {
  zsh = 'zsh',
  bash = 'bash',
  sh = 'sh',
  pwsh = 'pwsh',
  powershell = 'powershell',
}

return M
