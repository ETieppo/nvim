local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

return {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
