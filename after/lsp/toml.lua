local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  deps = {
    { cmd = 'tombi' },
  },
}

lang_mod.record_fmt {
  formatter = 'tombi',
}

return {
  cmd = {
    'tombi',
    'lsp',
  },
  filetypes = { lang_name },
  root_markers = { '.git' },
}
