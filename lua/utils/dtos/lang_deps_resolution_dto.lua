---@class LangDepsResolutionDto
---@field deps DepProps[]
---@field unresolved_references string[]

local LangDepsResolutionDto = {}

---@return LangDepsResolutionDto
function LangDepsResolutionDto.new()
  return {
    deps = {},
    unresolved_references = {},
  }
end

return LangDepsResolutionDto
