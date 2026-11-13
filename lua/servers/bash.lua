local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_filename()

deps.record_lang_deps {
  short = 'sh',
  deps = {
    {
      cmd = 'bash-language-server',
      depends_on = 'bun',
      install_command = 'bun add -g bash-language-server',
    },
    { cmd = 'shellcheck' },
    { cmd = 'shfmt' },
  },
}

lsp.record_lsp {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { lang_name, 'sh', 'zsh' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
