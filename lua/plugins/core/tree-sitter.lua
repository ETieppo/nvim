return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  branch = 'master',
  config = function()
    require('nvim-treesitter.configs').setup {
      ensure_installed = {
        'c',
        'lua',
        'vim',
        'vimdoc',
        'query',
        'html',
        'markdown',
        'markdown_inline',
        'bash',
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}
