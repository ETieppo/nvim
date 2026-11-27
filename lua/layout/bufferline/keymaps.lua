local helpers = require 'utils.helpers'

helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-l>',
  '<cmd>BufferLineCycleNext<CR>',
  { desc = 'Next buffer' }
)
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-h>',
  '<cmd>BufferLineCyclePrev<CR>',
  { desc = 'Previous buffer' }
)
vim.keymap.set(
  'n',
  '<leader>bod',
  '<cmd>BufferLineCloseOthers<CR>',
  { desc = '[B]uffer [O]thers [D]elete' }
)
