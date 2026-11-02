local lang_mod = require 'langs.core'

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
  filetypes = lang_mod.get_javascript_filetypes(),
  root_markers = {
    '.oxlintrc.json',
    '.oxlintrc.jsonc',
    'oxlint.config.ts',
    'package.json',
    '.git',
  },
}
