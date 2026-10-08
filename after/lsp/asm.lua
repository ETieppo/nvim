local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

return {
  cmd = { 'asm-lsp' },
  filetypes = { lang_name, 's' },
  root_markers = { '.asm-lsp.toml', '.git' },
}
