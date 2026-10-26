local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'
local PackageManager = require 'utils.package_managers.package_manager'
local PacmanPackageManager =
  require 'utils.package_managers.pacman_package_manager'
local ScoopPackageManager =
  require 'utils.package_managers.scoop_package_manager'

---@alias ExecutableCheckProps fun(name: string): boolean

---@class PackageManagerDefinitionProps
---@field class PackageManager
---@field install_args string[]
---@field requires_sudo boolean

local M = {}

---@type table<PackageManagerNameEnum, PackageManagerDefinitionProps>
local definitions = {
  [PackageManagerNameEnum.pacman] = {
    class = PacmanPackageManager,
    install_args = { '-S', '--needed', '--noconfirm' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.apt] = {
    class = PackageManager,
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.dnf] = {
    class = PackageManager,
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.zypper] = {
    class = PackageManager,
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.apk] = {
    class = PackageManager,
    install_args = { 'add' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.brew] = {
    class = PackageManager,
    install_args = { 'install' },
    requires_sudo = false,
  },
  [PackageManagerNameEnum.scoop] = {
    class = ScoopPackageManager,
    install_args = { 'install' },
    requires_sudo = false,
  },
}

---@type table<OsNameEnum, PackageManagerNameEnum[]>
local candidates_by_os = {
  [OsNameEnum.macos] = { PackageManagerNameEnum.brew },
  [OsNameEnum.linux] = {
    PackageManagerNameEnum.pacman,
    PackageManagerNameEnum.apt,
    PackageManagerNameEnum.dnf,
    PackageManagerNameEnum.zypper,
    PackageManagerNameEnum.apk,
  },
}

---@param name PackageManagerNameEnum
---@param has_executable ExecutableCheckProps
---@return PackageManager
function M.create(name, has_executable)
  local definition = definitions[name]
  local has_aur_helper = name == PackageManagerNameEnum.pacman
    and has_executable(PackageManagerNameEnum.yay)

  return definition.class:new {
    name = name,
    install_args = definition.install_args,
    requires_sudo = definition.requires_sudo,
    is_available = has_executable(name),
    aur_helper_name = has_aur_helper and PackageManagerNameEnum.yay or nil,
  }
end

---@param os_name OsNameEnum|nil
---@param has_executable ExecutableCheckProps
---@return PackageManager|nil
function M.detect(os_name, has_executable)
  if os_name == OsNameEnum.windows then
    return M.create(PackageManagerNameEnum.scoop, has_executable)
  end

  for _, name in ipairs(candidates_by_os[os_name] or {}) do
    if has_executable(name) then return M.create(name, has_executable) end
  end

  return nil
end

return M
