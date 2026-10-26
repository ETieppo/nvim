local lang_mod = require 'utils.lang_mod'

lang_mod.record_lang_deps {
  depends_on = 'prettierd',
  deps = {
    {
      cmd = 'vscode-json-language-server',
      install_command = 'bun add -g vscode-langservers-extracted',
    },
  },
}

lang_mod.record_fmt {
  formatter = 'prettierd',
}

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
}
