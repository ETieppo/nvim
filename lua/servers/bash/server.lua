local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

deps.record_toolchain { short = 'sh' }

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
  filetypes = { lang_name, 'sh' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
