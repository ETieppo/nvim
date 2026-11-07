local lang_name = require('utils.helpers').get_this_filename()
local lsp = require 'core.lsp'
local docs= require 'core.docs'
local lang_deps = require 'core.lang_registry'

docs.docs_ignore()

lang_deps.record_lang_deps {
  short = 'yml',
  deps = {
    {
      cmd = 'yaml-language-server',
      depends_on = 'bun',
      install_command = 'bun add -g yaml-language-server',
    },
  },
}

lsp.record_lsp {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { lang_name, 'yml' },
  root_markers = {},
}
