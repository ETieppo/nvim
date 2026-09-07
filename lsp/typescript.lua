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
