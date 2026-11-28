local lsp = require 'core.lsp.registry'
local def = require 'servers.codeterraform.def'

lsp.record_lsp {
  cmd = { 'bun', def.SERVER_DIRECTORY .. '/server.cjs', '--stdio' },
  filetypes = def.filetypes,
  root_markers = { def.ROOT_MARKER },
  workspace_required = true,
}
