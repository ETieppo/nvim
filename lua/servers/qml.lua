local lang_deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local docs= require 'core.docs.registry'
local lang_name = require('utils.helpers').get_this_filename()

docs.docs_ignore()

lang_deps.record_lang_deps {
  treesitter = { 'qmljs' },
  deps = {
    {
      cmd = 'qmlls6',
      push_env_source = '/usr/lib/qt6/bin',
      os = { linux = 'qt6-languageserver' },
    },
    {
      cmd = 'qmlformat',
      os = {
        linux = 'qt6-declarative',
      },
    },
  },
}

lsp.record_lsp {
  cmd = { 'qmlls6' },
  filetypes = { lang_name },
  root_markers = {},
}
