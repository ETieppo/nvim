local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
