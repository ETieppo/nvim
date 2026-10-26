---@class InstallPlanDto
---@field commands string[]
---@field installed string[]
---@field skipped string[]
---@field uses_package_manager boolean

local InstallPlanDto = {}

---@return InstallPlanDto
function InstallPlanDto.new()
  return {
    commands = {},
    installed = {},
    skipped = {},
    uses_package_manager = false,
  }
end

return InstallPlanDto
