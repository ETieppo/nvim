local plugins = require 'deps.plugins'

plugins.record {
  'kylechui/nvim-surround',
  event = { 'BufReadPost', 'BufNewFile' },
  opts = {},
}
