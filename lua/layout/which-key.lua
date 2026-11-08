local plugins = require 'deps.plugins'

plugins.record {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  ---@module 'which-key'
  ---@type wk.Opts
  opts = {
    delay = 500,
    icons = { mappings = vim.g.have_nerd_font },

    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
      { '<leader>k', group = 'kanban' },
      { '<leader>kb', group = 'board' },
      { '<leader>kn', group = 'new' },
      { '<leader>kc', group = 'card' },
      { '<leader>kd', group = 'date' },
      { '<leader>kl', group = 'list' },
    },
  },
}
