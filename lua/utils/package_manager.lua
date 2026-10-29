local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'
local PackageResolutionDto = require 'utils.dtos.package_resolution_dto'

---@alias ExecutableCheckProps fun(name: string): boolean
---@alias CommandOutputReaderProps fun(command: string): string|nil
---@alias InstallConfirmationProps fun(package_manager_name: PackageManagerNameEnum, package_name: string): boolean

---@class PackageNameVariantProps
---@field suffix string
---@field requires_confirmation boolean

---@class PackageManagerDefinitionProps
---@field install_args string[]
---@field requires_sudo boolean
---@field uses_buckets? boolean
---@field bootstrap_commands? string[]
---@field query_executable? string
---@field exact_query_args? string
---@field fallback_chain? PackageManagerNameEnum[]

---@class PackageManagerProps : PackageManagerDefinitionProps
---@field name PackageManagerNameEnum
---@field is_available boolean
---@field resolution_sources PackageManager[]

---@class PackageManager : PackageManagerProps
local PackageManager = {}
PackageManager.__index = PackageManager

---@type PackageNameVariantProps[]
local PACKAGE_NAME_VARIANTS = {
  { suffix = '', requires_confirmation = false },
  { suffix = '-git', requires_confirmation = false },
  { suffix = '-bin', requires_confirmation = true },
}

---@type table<PackageManagerNameEnum, PackageManagerDefinitionProps>
local definitions = {
  [PackageManagerNameEnum.pacman] = {
    install_args = { '-S', '--needed', '--noconfirm' },
    requires_sudo = true,
    exact_query_args = '-Si',
    fallback_chain = { PackageManagerNameEnum.yay, PackageManagerNameEnum.brew },
  },
  [PackageManagerNameEnum.yay] = {
    install_args = { '-S', '--needed', '--noconfirm', '--aur' },
    requires_sudo = false,
    exact_query_args = '-Si --aur',
  },
  [PackageManagerNameEnum.apt] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
    query_executable = 'apt-cache',
    exact_query_args = 'show',
    fallback_chain = { PackageManagerNameEnum.brew },
  },
  [PackageManagerNameEnum.dnf] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
    exact_query_args = 'info -q',
    fallback_chain = { PackageManagerNameEnum.brew },
  },
  [PackageManagerNameEnum.zypper] = {
    install_args = { 'install', '-y' },
    requires_sudo = true,
    exact_query_args = '--non-interactive search --match-exact',
    fallback_chain = { PackageManagerNameEnum.brew },
  },
  [PackageManagerNameEnum.apk] = {
    install_args = { 'add' },
    requires_sudo = true,
    exact_query_args = 'search -x',
    fallback_chain = { PackageManagerNameEnum.brew },
  },
  [PackageManagerNameEnum.brew] = {
    install_args = { 'install' },
    requires_sudo = false,
    exact_query_args = 'info --formula',
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
    PackageManagerNameEnum.brew,
  },
}

---@param name PackageManagerNameEnum
---@param has_executable ExecutableCheckProps
---@return PackageManager
local function create_without_fallbacks(name, has_executable)
  return setmetatable(
    vim.tbl_extend('force', definitions[name], {
      name = name,
      is_available = has_executable(name),
      resolution_sources = {},
    }),
    PackageManager
  )
end

---@param name PackageManagerNameEnum
---@param has_executable ExecutableCheckProps
---@return PackageManager
function PackageManager.create(name, has_executable)
  local package_manager = create_without_fallbacks(name, has_executable)
  table.insert(package_manager.resolution_sources, package_manager)

  for _, fallback_name in ipairs(package_manager.fallback_chain or {}) do
    local fallback = create_without_fallbacks(fallback_name, has_executable)
    if fallback.is_available then
      table.insert(package_manager.resolution_sources, fallback)
    end
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

---@param package_name string
---@param read_command_output CommandOutputReaderProps
---@return boolean
function PackageManager:has_package(package_name, read_command_output)
  if not self.exact_query_args then return true end

  local output = read_command_output(table.concat({
    self.query_executable or self.name,
    self.exact_query_args,
    package_name,
  }, ' '))
  return output ~= nil and vim.trim(output) ~= ''
end

---@param package_name string
---@param read_command_output CommandOutputReaderProps
---@param confirm_install InstallConfirmationProps
---@return PackageResolutionDto|nil
function PackageManager:resolve(
  package_name,
  read_command_output,
  confirm_install
)
  for _, variant in ipairs(PACKAGE_NAME_VARIANTS) do
    local variant_name = package_name .. variant.suffix
    for _, source in ipairs(self.resolution_sources) do
      if
        source:has_package(variant_name, read_command_output)
        and (
          not variant.requires_confirmation
          or confirm_install(source.name, variant_name)
        )
      then
        return PackageResolutionDto.new(source, variant_name)
      end
    end
  end

  return nil
end

---@param package_name string
---@return string
function PackageManager:build_install_command(package_name)
  local bucket = self.uses_buckets and package_name:match '^([^/]+)/'
  local parts = self.requires_sudo and { 'sudo', self.name } or { self.name }
  vim.list_extend(parts, self.install_args)
  table.insert(parts, package_name)

  local install = table.concat(parts, ' ')
  if bucket then return 'scoop bucket add ' .. bucket .. ' ; ' .. install end
  return install
end

---@return string[]
function PackageManager:get_bootstrap_commands()
  if self.is_available then return {} end
  return vim.list_slice(self.bootstrap_commands or {})
end

return PackageManager
