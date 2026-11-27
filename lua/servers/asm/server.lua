local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

dap.record_dap { adapter = 'lldb' }

lsp.record_lsp {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name },
  root_markers = { '.asm-lsp.toml', '.git' },
}
