local plugins = require 'deps.plugins'
local treesitter = require 'core.treesitter.registry'

treesitter.record_treesitter 'markdown'
treesitter.record_treesitter 'markdown_inline'

plugins.record {
  'etieppo/scaled_markdown',
  ft = 'markdown',
  opts = {},
}
