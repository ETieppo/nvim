local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.docs_ignore()

lang_mod.record_lang_deps {
  deps = {
    { cmd = 'tombi' },
  },
}

lang_mod.record_fmt {
  formatter = 'tombi',
}

---@type vim.lsp.Config
return {
  cmd = {
    'tombi',
    'lsp',
  },
  filetypes = { lang_name },
  root_markers = { '.git' },
}
