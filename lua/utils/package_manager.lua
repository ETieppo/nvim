local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'

---@alias ExecutableCheckProps fun(name: string): boolean

---@class PackageManagerDefinitionProps
---@field install_args string[]
---@field requires_sudo boolean
---@field fallback_name? PackageManagerNameEnum
---@field uses_buckets? boolean
---@field bootstrap_commands? string[]

---@class PackageManagerProps : PackageManagerDefinitionProps
---@field name PackageManagerNameEnum
---@field is_available boolean

---@class PackageManager : PackageManagerProps
local PackageManager = {}
PackageManager.__index = PackageManager

---@type table<PackageManagerNameEnum, PackageManagerDefinitionProps>
local definitions = {
  [PackageManagerNameEnum.pacman] = {
    install_args = { '-S', '--needed', '--noconfirm' },
    requires_sudo = true,
    fallback_name = PackageManagerNameEnum.yay,
  },
  [PackageManagerNameEnum.apt] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.dnf] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.zypper] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.apk] = {
    install_args = { 'add' },
    requires_sudo = true,
  },
  [PackageManagerNameEnum.brew] = {
    install_args = { 'install' },
    requires_sudo = false,
  },
  [PackageManagerNameEnum.scoop] = {
    install_args = { 'install' },
    requires_sudo = false,
    uses_buckets = true,
    bootstrap_commands = {
      'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
      'irm get.scoop.sh | iex',
    },
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
function PackageManager.create(name, has_executable)
  local package_manager = setmetatable(
    vim.tbl_extend('force', definitions[name], {
      name = name,
      is_available = has_executable(name),
    }),
    PackageManager
  )

  local fallback_name = package_manager.fallback_name
  if fallback_name and not has_executable(fallback_name) then
    package_manager.fallback_name = nil
  end
  return package_manager
end

---@param os_name OsNameEnum|nil
---@param has_executable ExecutableCheckProps
---@return PackageManager|nil
function PackageManager.detect(os_name, has_executable)
  if os_name == OsNameEnum.windows then
    return PackageManager.create(PackageManagerNameEnum.scoop, has_executable)
  end

  for _, name in ipairs(candidates_by_os[os_name] or {}) do
    if has_executable(name) then
      return PackageManager.create(name, has_executable)
    end
  end

  return nil
end

---@param executable string
---@param use_sudo boolean
---@param packages string[]
---@return string
function PackageManager:build_invocation(executable, use_sudo, packages)
  local parts = use_sudo and { 'sudo', executable } or { executable }
  vim.list_extend(parts, self.install_args)
  vim.list_extend(parts, packages)
  return table.concat(parts, ' ')
end

---@param packages string[]
---@return string
function PackageManager:build_install_command(packages)
  local commands, added_buckets = {}, {}

  for _, package in ipairs(self.uses_buckets and packages or {}) do
    local bucket = package:match '^([^/]+)/'
    if bucket and not added_buckets[bucket] then
      added_buckets[bucket] = true
      table.insert(commands, 'scoop bucket add ' .. bucket)
    end
  end

  local install = self:build_invocation(self.name, self.requires_sudo, packages)
  if self.fallback_name then
    install = install
      .. ' || '
      .. self:build_invocation(self.fallback_name, false, packages)
  end

  table.insert(commands, install)
  return table.concat(commands, ' ; ')
end

---@return string[]
function PackageManager:get_bootstrap_commands()
  if self.is_available then return {} end
  return vim.list_slice(self.bootstrap_commands or {})
end

return PackageManager
