return {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      { path = 'lazy.nvim', words = { 'LazySpec' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
      { path = 'blink.cmp', words = { 'blink%.cmp' } },
      { path = 'gitsigns.nvim', words = { 'Gitsigns' } },
      { path = 'todo-comments.nvim', words = { 'TodoOptions' } },
      { path = 'neo-tree.nvim', words = { 'neotree' } },
      { path = 'which-key.nvim', words = { 'wk%.' } },
    },
  },
  config = function(_, opts)
    table.insert(require('lazydev.lsp').supported_clients, 'lua')
    require('lazydev').setup(opts)
  end,
}
