local plugins = require 'deps.plugins'

plugins.record {
  -- 'nvim-mini/mini.surround',
  'kylechui/nvim-surround',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {},
}
