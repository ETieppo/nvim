local plugins = require 'deps.plugins'

plugins.record {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  event = 'InsertEnter',
  build = 'make install_jsregexp',
  config = function()
    require('luasnip.loaders.from_lua').lazy_load {
      paths = { vim.fn.stdpath 'config' .. '/lua/servers' },
    }
  end,
}
