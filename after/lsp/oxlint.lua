local lang_mod = require 'utils.lang_mod'

lang_mod.treesitter_ignore()
lang_mod.docs_ignore()

lang_mod.record_lang_deps {
  depends_on = 'bun',
  deps = {
    {
      cmd = 'oxlint',
      install_command = 'bun i -g oxlint',
    },
    {
      cmd = 'oxfmt',
      install_command = 'bun i -g oxfmt',
    },
  },
}

return {
  cmd = { 'oxlint', '--lsp' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_markers = {
    '.oxlintrc.json',
    '.oxlintrc.jsonc',
    'oxlint.config.ts',
    'package.json',
    '.git',
  },
}
