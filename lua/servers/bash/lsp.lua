local lsp = require 'core.lsp.registry'
local def = require 'servers.bash.def'

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g bash-language-server && ln -s "$(which bun)" ~/.bun/bin/node',
    },
    { cmd = 'shellcheck' },
    { cmd = 'shfmt' },
  },
  cmd = { 'bash-language-server', 'start' },
  filetypes = def.filetypes,
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
