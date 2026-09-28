return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    {
      'kristijanhusak/vim-dadbod-completion',
      ft = { 'sql', 'mysql', 'plsql' },
      lazy = true,
    },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_use_nvim_notify = 1
  end,
  config = function()
    vim.api.nvim_create_autocmd('User', {
      group = vim.api.nvim_create_augroup('user-dbui', { clear = true }),
      pattern = { '*DBExecutePre', '*DBExecutePost' },
      callback = function()
        local mopt = vim.o.messagesopt
        if not mopt:find('hit-enter', 1, true) then return end
        vim.o.messagesopt = (mopt:gsub('hit%-enter', 'wait:0'))
        vim.schedule(function() vim.o.messagesopt = mopt end)
      end,
    })
  end,
}
