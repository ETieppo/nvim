local M = {}

---@type enum
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

return M
