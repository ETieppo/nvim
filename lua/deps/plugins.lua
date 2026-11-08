local profile = require 'deps.profile'

local M = {}
local plugins = {}

function M.record(plugin)
  if plugin.extra and profile.is_min_profile() then return end
  table.insert(plugins, plugin)
end

function M.get_plugins() return plugins end

return M
