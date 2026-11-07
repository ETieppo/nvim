local docs= require 'core.docs'
local lsp = require 'core.lsp'
local lang_deps = require 'core.lang_registry'
local fmt = require 'core.fmt'
local lang_name = require('utils.helpers').get_this_filename()

docs.docs_ignore()

lang_deps.record_lang_deps {
  deps = {
    { cmd = 'tombi' },
  },
}

fmt.record_fmt {
  formatter = 'tombi',
}

lsp.record_lsp {
  cmd = {
    'tombi',
    'lsp',
  },
  filetypes = { lang_name },
  root_markers = { '.git' },
}
