---@class IgnorableRegistryProps
---@field recorded string[]
---@field ignored string[]

local M = {}

---@return IgnorableRegistryProps
function M.new() return { recorded = {}, ignored = {} } end

---@param registry IgnorableRegistryProps
---@param name string
function M.record(registry, name)
  if
    not vim.list_contains(registry.ignored, name)
    and not vim.list_contains(registry.recorded, name)
  then
    table.insert(registry.recorded, name)
  end
end

---@param registry IgnorableRegistryProps
---@param name string
function M.ignore(registry, name)
  if not vim.list_contains(registry.ignored, name) then
    table.insert(registry.ignored, name)
  end
end

---@param registry IgnorableRegistryProps
---@return string[]
function M.get_recorded(registry) return vim.deepcopy(registry.recorded) end

return M
