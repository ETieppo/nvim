local treesitter = require 'core.treesitter.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local deps = require 'core.lang.registry'

treesitter.treesitter_ignore()
docs.docs_ignore()

deps.record_lang_deps {
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
