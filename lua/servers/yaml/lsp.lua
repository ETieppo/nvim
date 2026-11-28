local lsp = require 'core.lsp.registry'
local def = require 'servers.yaml.def'

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g yaml-language-server',
    },
  },
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = def.filetypes,
  root_markers = {},
}
