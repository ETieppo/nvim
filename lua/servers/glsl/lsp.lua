local lsp = require 'core.lsp.registry'
local def = require 'servers.glsl.def'

lsp.record_lsp {
  deps = { { install_command = 'glsl_analyzer-bin' } },
  cmd = { 'glsl_analyzer' },
  filetypes = def.filetypes,
  root_markers = { '.git' },
}
