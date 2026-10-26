local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  tree_sitter_name = 'bash',
  short = 'bash',
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

lang_mod.record_docs { docs = { 'bash' } }

return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { lang_name, 'bash' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
