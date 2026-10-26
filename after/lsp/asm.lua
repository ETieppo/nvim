local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

return {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name },
  root_markers = { '.asm-lsp.toml', '.git' },
}
