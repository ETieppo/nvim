require('utils.lang_deps').register_lang_deps({
  lang = 'ts',
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
})

return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
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
