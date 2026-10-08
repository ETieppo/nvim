local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'utils.lang'

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'ts',
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
      cmd = 'tsc',
      install_command = 'bun i -g typescript',
    },
  },
}

lang_mod.record_fmt {
  { lang = 'javascript', formatter = 'prettierd' },
  { lang = 'javascriptreact', formatter = 'prettierd' },
  { lang = 'typescript', formatter = 'prettierd' },
  { lang = 'typescriptreact', formatter = 'prettierd' },
  { lang = 'html', formatter = 'prettierd' },
  { lang = 'htmlangular', formatter = 'prettierd' },
  { lang = 'json', formatter = 'prettierd' },
}

return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = {
    lang_name,
    'javascript',
    'javascriptreact',
    'typescriptreact',
  },

  root_markers = {
    'jsconfig.json',
    'tsconfig.json',
    'package.json',
    '.git',
  },

  init_options = {
    hostInfo = 'neovim',
  },
}
