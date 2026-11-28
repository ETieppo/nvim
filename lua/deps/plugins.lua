local profile = require 'deps.profile'

local M = {}
---@type table<string, boolean>
local SPEC_FILE_NAMES = { ['plugin.lua'] = true, ['test.lua'] = true }
local plugins = {}

function M.record(plugin)
  if plugin.extra and profile.is_min_profile() then return end
  table.insert(plugins, plugin)
end

function M.get_plugins() return plugins end

---@param file_name string
---@return boolean
function M.is_spec_file(file_name) return SPEC_FILE_NAMES[file_name] == true end

return M
