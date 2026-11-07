local profile = require'settings.profile'

local M = {}
local plugins = {}

function M.record(plugin)
  -- TODO: do validations
  table.insert(plugins,plugin)
end

function M.get_plugins()
  if profile.is_min_profile() then
    local min_plugins = {}
    for _,p in ipairs(plugins) do
      if not p.extra then
        vim.list_extend(min_plugins,p)
      end
    end
    return min_plugins
  end
  return plugins
end

return M
