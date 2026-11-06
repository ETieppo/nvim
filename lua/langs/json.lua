local lang_mod = require 'langs.core'
---@type string[]
local filetypes = { 'json', 'jsonc' }

lang_mod.docs_ignore()

lang_mod.record_lang_deps {
  depends_on = { 'bun', 'oxfmt' },
  deps = {
    {
      cmd = 'vscode-json-language-server',
      install_command = 'bun add -g vscode-langservers-extracted',
    },
  },
}

lang_mod.record_fmt {
  lang = filetypes,
  formatter = 'oxfmt',
}

---@type vim.lsp.Config
return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = filetypes,
  root_markers = { '.git' },
}
