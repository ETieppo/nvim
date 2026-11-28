local lsp = require 'core.lsp.registry'
local def = require 'servers.docker.def'

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g dockerfile-language-server-nodejs',
    },
  },
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = def.filetypes,
}
