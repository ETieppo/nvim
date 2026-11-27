local lang_name = require('utils.helpers').get_this_filename()
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local deps = require 'core.lang.registry'

docs.docs_ignore()

deps.record_toolchain { short = 'yml' }

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g yaml-language-server',
    },
  },
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { lang_name, 'yml' },
  root_markers = {},
}
