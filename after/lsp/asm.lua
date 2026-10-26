local lang_mod = require 'utils.lang_mod'
local dap_mod = require 'utils.dap_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = { dap_mod.build_lldb_launch_configuration() },
}

return {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name },
  root_markers = { '.asm-lsp.toml', '.git' },
}
