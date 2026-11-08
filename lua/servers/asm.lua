local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_filename()

dap.record_dap {
  adapter = 'lldb',
  configurations = { dap.build_lldb_launch_configuration() },
}

lsp.record_lsp {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name },
  root_markers = { '.asm-lsp.toml', '.git' },
}
