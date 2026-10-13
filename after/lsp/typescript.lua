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

for _, l in ipairs({
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'html',
  'htmlangular',
  'json',
}) do
  lang_mod.record_fmt {
    lang = l,
    formatter = 'prettierd'
  }
end

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
