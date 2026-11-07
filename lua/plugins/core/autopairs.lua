local plugins = require 'deps.plugins'

---@module 'lazy'
---@type LazySpec

plugins.record {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},
}
