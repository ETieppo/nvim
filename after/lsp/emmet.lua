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
