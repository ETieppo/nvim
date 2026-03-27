return {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPost', 'BufNewFile' },
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
        'css',
        'markdown',
        'markdown_inline',
        'bash',
        'sql',
        'hurl',
      },
      highlight = { enable = true },
      indent = { enable = true },
    }
  end,
}
