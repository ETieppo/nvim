local fmt = require 'core.fmt'
local lsp = require 'core.lsp'
local docs = require 'core.docs'
local lang_deps = require 'core.lang_registry'

---@type string[]
local filetypes = { 'json', 'jsonc' }

docs.docs_ignore()

lang_deps.record_lang_deps {
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
