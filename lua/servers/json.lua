local fmt = require 'core.formatter.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local deps = require 'core.lang.registry'

---@type string[]
local filetypes = { 'json', 'jsonc' }

docs.docs_ignore()

deps.record_toolchain {}

fmt.record_fmt {
  lang = filetypes,
  formatter = 'oxfmt',
}

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g vscode-langservers-extracted',
    },
  },
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = filetypes,
  root_markers = { '.git' },
}
