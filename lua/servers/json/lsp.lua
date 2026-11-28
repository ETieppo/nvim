local lsp = require 'core.lsp.registry'
local def = require 'servers.json.def'

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g vscode-langservers-extracted',
    },
  },
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = def.filetypes,
  root_markers = { '.git' },
}
