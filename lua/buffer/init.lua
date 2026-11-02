local helpers = require 'utils.helpers'
local path = vim.fn.stdpath 'config' .. '/lua/buffer'

for _, name in ipairs(helpers.find_lua_module_names(path)) do
  require('buffer.' .. name)
end
