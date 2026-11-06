local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
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

---@type vim.lsp.Config
return {
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
