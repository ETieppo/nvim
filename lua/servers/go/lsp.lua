local lsp = require 'core.lsp.registry'
local def = require 'servers.go.def'

lsp.record_lsp {
  deps = {
    {
      install_command = 'go install golang.org/x/tools/gopls@latest',
      push_to_path = '.go/bin',
    },
  },
  cmd = { 'gopls' },
  filetypes = def.filetypes,
  root_markers = { 'go.work', 'go.mod', '.git', '.hg' },
  init_options = { usePlaceholders = true },
}
