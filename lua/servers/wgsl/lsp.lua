local lsp = require 'core.lsp.registry'
local def = require 'servers.wgsl.def'

lsp.record_lsp {
  cmd = { 'wgsl-analyzer' },
  filetypes = def.filetypes,
  root_markers = { 'wesl.toml', '.git' },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
