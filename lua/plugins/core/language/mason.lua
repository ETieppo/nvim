local os = require 'utils.os'

local ensure_installed = os.has_deps 'gcc'
    and os.has_deps 'tree-sitter'
    and {
      'css-lsp',
      'lua_ls',
      'selene',
      'ts_ls',
      'jsonls',
      'stylua',
      'prettier',
      'emmet-language-server',
      'angular-language-server',
      'markdown-oxide',
    }
  or {}

return {
  {
    'mason-org/mason.nvim',
    opts = {},
  },
  {
    'neovim/nvim-lspconfig',
  },
  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      'mason-org/mason.nvim',
    },
    opts = {},
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'mason-org/mason.nvim' },
    opts = {
      ensure_installed,
    },
  },
}
