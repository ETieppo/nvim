local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = { lang_mod.build_lldb_launch_configuration() },
}

return {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name },
  root_markers = { '.asm-lsp.toml', '.git' },
}
