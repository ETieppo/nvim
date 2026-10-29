---@class PackageResolutionDto
---@field package_manager PackageManager
---@field package_name string

local PackageResolutionDto = {}

---@param package_manager PackageManager
---@param package_name string
---@return PackageResolutionDto
function PackageResolutionDto.new(package_manager, package_name)
  return {
    package_manager = package_manager,
    package_name = package_name,
  }
end

return PackageResolutionDto
