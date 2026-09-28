local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
  cmd = { 'vscode-css-language-server', '--stdio' },
  filetypes = { 'css', 'scss', 'less' },
  root_markers = { 'package.json', '.git' },
  capabilities = capabilities,
  init_options = { provideFormatter = true },
  settings = {
    css = { validate = true, lint = { unknownAtRules = 'ignore' } },
    scss = { validate = true, lint = { unknownAtRules = 'ignore' } },
    less = { validate = true, lint = { unknownAtRules = 'ignore' } },
  },
}
