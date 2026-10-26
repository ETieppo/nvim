local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.ignore_treesitter_install()

return {
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
  },
  root_markers = { '.git' },
  init_options = {
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = 'always',
    showSuggestionsAsSnippets = false,
  },
}
