local plugins = require 'deps.plugins'

plugins.record {
  'folke/todo-comments.nvim',
  event = { 'BufReadPost', 'BufNewFile' },
  ---@module 'todo-comments'
  ---@type TodoOptions
  opts = { signs = false },
}
