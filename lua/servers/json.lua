local fmt = require 'core.formatter.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local deps = require 'core.lang.registry'

---@type string[]
local filetypes = { 'json', 'jsonc' }

docs.docs_ignore()

deps.record_lang_deps {
  depends_on = { 'bun', 'oxfmt' },
  deps = {
    {
      cmd = 'vscode-json-language-server',
      install_command = 'bun add -g vscode-langservers-extracted',
    },
  },
}

fmt.record_fmt {
  lang = filetypes,
  formatter = 'oxfmt',
}

lsp.record_lsp {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = filetypes,
  root_markers = { '.git' },
}
