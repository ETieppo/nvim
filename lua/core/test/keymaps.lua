vim.keymap.set(
  'n',
  '<leader>tt',
  function() require('neotest').run.run() end,
  { desc = '[T]est [T]his' }
)
vim.keymap.set(
  'n',
  '<leader>tf',
  function() require('neotest').run.run(vim.fn.expand '%') end,
  { desc = '[T]est [F]ile' }
)
vim.keymap.set(
  'n',
  '<leader>td',
  function() require('neotest').run.run { suite = false, strategy = 'dap' } end,
  { desc = '[T]est [D]ebug' }
)
vim.keymap.set(
  'n',
  '<leader>tr',
  function() require('neotest').summary.toggle() end,
  { desc = '[T]est [R]eport' }
)
vim.keymap.set(
  'n',
  '<leader>to',
  function() require('neotest').output.open { enter = true } end,
  { desc = '[T]est [O]utput' }
)
vim.keymap.set(
  'n',
  '<leader>ts',
  function() require('neotest').run.stop() end,
  { desc = '[T]est [S]top' }
)
vim.keymap.set(
  'n',
  '<leader>ta',
  function() require('neotest').run.run { suite = true } end,
  { desc = '[T]est [A]ll' }
)
