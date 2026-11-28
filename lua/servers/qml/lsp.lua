local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  deps = {
    {
      push_to_path = '/usr/lib/qt6/bin',
      os = { linux = 'qt6-languageserver' },
    },
    { cmd = 'qmlformat', os = { linux = 'qt6-declarative' } },
  },
  cmd = { 'qmlls6' },
  filetypes = { lang_name },
  root_markers = {},
}
