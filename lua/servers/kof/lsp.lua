local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  cmd = {
    'kof',
    'lsp',
  },
  filetypes = { lang_name },
  root_markers = {
    'kofdeps',
    'kof.toml',
    '.git',
  },
  on_init = lsp.convert_completion_kind_names_on_init,
}
