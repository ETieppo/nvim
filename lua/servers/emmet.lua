local treesitter = require 'core.treesitter'
local lsp = require 'core.lsp'
local docs = require 'core.docs'
local lang_deps = require 'core.lang_registry'

treesitter.treesitter_ignore()
docs.docs_ignore()

lang_deps.record_lang_deps {
  deps = {
    {
      cmd = 'emmet-language-server',
      depends_on = 'bun',
      install_command = 'bun i -g @olrtg/emmet-language-server',
    },
  },
}

lsp.record_lsp {
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = {
    'html',
    'css',
    'scss',
    'sass',
    'less',
    'javascriptreact',
    'typescriptreact',
    'vue',
    'svelte',
    'astro',
    'angular',
  },
  root_markers = { '.git' },
  init_options = {
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = 'always',
    showSuggestionsAsSnippets = false,
  },
}
