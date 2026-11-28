local lsp = require 'core.lsp.registry'
local def = require 'servers.tofu.def'

lsp.record_lsp {
  cmd = {
    'tofu-ls',
    'serve',
  },
  filetypes = def.filetypes,
  root_markers = {
    '.terraform',
    '.git',
  },
}
