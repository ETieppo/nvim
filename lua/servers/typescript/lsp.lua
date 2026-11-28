local lsp = require 'core.lsp.registry'
local def = require 'servers.typescript.def'

lsp.record_lsp {
  deps = { { install_command = 'bun i -g typescript' } },
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = def.filetypes,
  root_markers = {
    'jsconfig.json',
    'tsconfig.json',
    'package.json',
    '.git',
  },
  init_options = {
    hostInfo = 'neovim',
  },
}
