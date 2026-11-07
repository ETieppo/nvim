local profile = require 'settings.profile'

---@class TestAdapterProps
---@field [1] string
---@field module string
---@field opts? table

---@class TestModProps
local M = {}

---@type TestAdapterProps[]
local recorded_test_adapters = {}

---@param test_adapter TestAdapterProps
function M.record_test_adapter(test_adapter)
  if profile.is_max_profile() then
    table.insert(recorded_test_adapters, test_adapter)
  end
end

---@return TestAdapterProps[]
function M.get_test_adapters() return vim.deepcopy(recorded_test_adapters) end

return M
