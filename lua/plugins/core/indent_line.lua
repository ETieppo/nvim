return {
  'nvim-mini/mini.indentscope',
  version = false,
  opts = {
    symbol = '│',
    options = { try_as_border = true },
  },
  init = function() vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#7aa2f7' }) end,
}
