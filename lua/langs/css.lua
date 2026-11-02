local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'langs.core'
local filetypes = { lang_name, 'scss', 'less' }

lang_mod.record_fmt {
  lang = filetypes,
  formatter = 'prettierd',
}

lang_mod.record_docs { 'tailwindcss' }

return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = filetypes,
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
  init_options = { provideFormatter = true },
  settings = {
    css = { validate = true, lint = { unknownAtRules = 'ignore' } },
    scss = { validate = true, lint = { unknownAtRules = 'ignore' } },
    less = { validate = true, lint = { unknownAtRules = 'ignore' } },
  },
}
