local treesitter = require 'core.treesitter.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local lang_deps = require 'core.lang.registry'
require 'servers.typescript'

treesitter.treesitter_ignore()
docs.docs_ignore()

lang_deps.record_lang_deps {
  depends_on = 'bun',
  deps = {
    {
      cmd = 'oxlint',
      install_command = 'bun i -g oxlint',
    },
    {
      cmd = 'oxfmt',
      install_command = 'bun i -g oxfmt',
    },
  },
}

lsp.record_lsp {
  cmd = { 'oxlint', '--lsp' },
  filetypes = lang_deps.get_lang_filetypes 'typescript',
  root_markers = {
    '.oxlintrc.json',
    '.oxlintrc.jsonc',
    'oxlint.config.ts',
    'package.json',
    '.git',
  },
}
