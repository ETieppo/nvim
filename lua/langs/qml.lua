local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.docs_ignore()

lang_mod.record_lang_deps {
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

---@type vim.lsp.Config
return {
  cmd = { 'qmlls6' },
  filetypes = { lang_name },
  root_markers = {},
}
