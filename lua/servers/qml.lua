local lang_deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local lang_name = require('utils.helpers').get_this_filename()

docs.docs_ignore()

lang_deps.record_toolchain { treesitter = { 'qmljs' } }

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
