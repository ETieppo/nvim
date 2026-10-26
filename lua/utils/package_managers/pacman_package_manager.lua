local PackageManager = require 'utils.package_managers.package_manager'

---@class PacmanPackageManagerProps : PackageManagerProps
---@field aur_helper_name? PackageManagerNameEnum

---@class PacmanPackageManager : PackageManager
---@field aur_helper_name? PackageManagerNameEnum
local PacmanPackageManager = PackageManager:extend()

---@param packages string[]
---@return string
function PacmanPackageManager:build_install_command(packages)
  local pacman_command = PackageManager.build_install_command(self, packages)
  if not self.aur_helper_name then return pacman_command end

  local aur_command =
    self:build_invocation(self.aur_helper_name, false, packages)
  return pacman_command .. ' || ' .. aur_command
end

return PacmanPackageManager
