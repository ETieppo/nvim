local lsp = require 'core.lsp.registry'

lsp.record_lsp {
  deps = { { depends_on = 'bun', install_command = 'bun i -g oxlint' } },
  cmd = { 'oxlint', '--lsp' },
  filetypes = require('servers.oxlint.def').filetypes,
  root_markers = {
    '.oxlintrc.json',
    '.oxlintrc.jsonc',
    'oxlint.config.ts',
    'package.json',
    '.git',
  },
}
