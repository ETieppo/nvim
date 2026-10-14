local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'utils.lang'

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'bun',
      os = {
        unix = 'curl -fsSL https://bun.sh/install | bash',
        windows = 'powershell -c "irm bun.sh/install.ps1|iex"',
      },
    },
    {
      cmd = 'prettierd',
      install_command = 'bun i -g @fsouza/prettierd',
    },
    {
      cmd = "jsonls",
      install_command = "bun add -g vscode-langservers-extracted"
    }
  }
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'prettierd'
}

return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { '.git' },
}
