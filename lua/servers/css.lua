local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local docs = require 'core.docs.registry'
local lang_name = require('utils.helpers').get_this_filename()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

---@type string[]
local filetypes = { lang_name, 'scss', 'less' }

fmt.record_fmt {
  lang = filetypes,
  formatter = 'prettierd',
}

docs.record_docs { 'tailwindcss' }

lsp.record_lsp {
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
