local lang_mod = require 'utils.lang_mod'

lang_mod.treesitter_ignore()
lang_mod.docs_ignore()

lang_mod.record_lang_deps {
  deps = {
    {
      cmd = 'emmet-language-server',
      depends_on = 'bun',
      install_cmd = 'bun i -g @olrtg/emmet-language-server',
    },
  },
}

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
    'angular',
  },
  root_markers = { '.git' },
  init_options = {
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = 'always',
    showSuggestionsAsSnippets = false,
  },
}
