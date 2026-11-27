local docs = require 'core.docs.registry'
local lsp = require 'core.lsp.registry'
local deps = require 'core.lang.registry'
local fmt = require 'core.formatter.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

docs.docs_ignore()

deps.record_toolchain {}

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
