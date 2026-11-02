local helpers = require 'utils.helpers'
local path = vim.fn.stdpath 'config' .. '/lua/settings'

for _, name in ipairs(helpers.find_lua_module_names(path)) do
  require('settings.' .. name)
end
