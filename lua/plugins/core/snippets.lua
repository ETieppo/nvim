return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  build = 'make install_jsregexp',
  config = function()
    local ls = require 'luasnip'

    require('luasnip.loaders.from_lua').lazy_load {
      paths = { vim.fn.stdpath 'config' .. '/snippets' },
    }

    vim.keymap.set({ 'i', 's' }, '<Tab>', function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      else
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
      end
    end, { silent = true })
  end,
}
