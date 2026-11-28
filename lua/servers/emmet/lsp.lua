local lsp = require 'core.lsp.registry'
local def = require 'servers.emmet.def'

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun i -g @olrtg/emmet-language-server',
    },
  },
  cmd = { 'emmet-language-server', '--stdio' },
  filetypes = def.filetypes,
  root_markers = { '.git' },
  init_options = {
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = 'always',
    showSuggestionsAsSnippets = false,
  },
}
