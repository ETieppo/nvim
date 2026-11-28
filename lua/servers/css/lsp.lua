local lsp = require 'core.lsp.registry'
local def = require 'servers.css.def'

local STYLESHEET_SETTINGS =
  { validate = true, lint = { unknownAtRules = 'ignore' } }

lsp.record_lsp {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = def.filetypes,
  root_markers = { 'package.json', '.git' },
  capabilities = function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
    return capabilities
  end,
  init_options = { provideFormatter = true },
  settings = {
    css = STYLESHEET_SETTINGS,
    scss = STYLESHEET_SETTINGS,
    less = STYLESHEET_SETTINGS,
  },
}
