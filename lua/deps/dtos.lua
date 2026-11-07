---@class InstallPlanDto
---@field commands string[]
---@field installed string[]
---@field skipped string[]
---@field uses_package_manager boolean

---@class PackageResolutionDto
---@field package_manager PackageManager
---@field package_name string

---@class LangDepsResolutionDto
---@field deps DepProps[]
---@field unresolved_references string[]
local M = {}

M.LangDepsResolutionDto = {}
M.InstallPlanDto = {}
M.PackageResolutionDto = {}

---@param package_manager PackageManager
---@param package_name string
---@return PackageResolutionDto
function M.PackageResolutionDto.new(package_manager, package_name)
  return {
    package_manager = package_manager,
    package_name = package_name,
  }
end

---@return InstallPlanDto
function M.InstallPlanDto.new()
  return {
    commands = {},
    installed = {},
    skipped = {},
    uses_package_manager = false,
  }
end

---@return LangDepsResolutionDto
function M.LangDepsResolutionDto.new()
  return {
    deps = {},
    unresolved_references = {},
  }
end

return M
