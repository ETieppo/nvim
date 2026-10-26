local PackageManager = require 'utils.package_managers.package_manager'

---@class ScoopPackageManager : PackageManager
local ScoopPackageManager = PackageManager:extend()

---@param packages string[]
---@return string
function ScoopPackageManager:build_install_command(packages)
  local commands, added_buckets = {}, {}

  for _, package in ipairs(packages) do
    local bucket = package:match '^([^/]+)/'
    if bucket and not added_buckets[bucket] then
      added_buckets[bucket] = true
      table.insert(commands, 'scoop bucket add ' .. bucket)
    end
  end

  table.insert(commands, PackageManager.build_install_command(self, packages))
  return table.concat(commands, ' ; ')
end

---@return string[]
function ScoopPackageManager:get_bootstrap_commands()
  if self.is_available then return {} end
  return {
    'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
    'irm get.scoop.sh | iex',
  }
end

return ScoopPackageManager
