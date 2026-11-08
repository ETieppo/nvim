local file = require 'buffer.file'
local helpers = require 'utils.helpers'
local os_mod = require 'deps.sys'

-- Several --------------------------------------------------------------------
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = '[L]azy [O]pen' })
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Diagnostic [Q]uickfix list' }
)
vim.keymap.set(
  't',
  '<Esc><Esc>',
  '<C-\\><C-n>',
  { desc = 'Exit terminal mode' }
)

-- Line Operations -----------------------------------------------------------
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-j>',
  ':m .+1<CR>==',
  { desc = 'Move line down' }
)
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-k>',
  ':m .-2<CR>==',
  { desc = 'Move line up' }
)
helpers.set_alt_and_cmd_keymap(
  'x',
  '<M-j>',
  ":silent! m '>+1<CR>gv=gv",
  { desc = 'Move selection down' }
)
helpers.set_alt_and_cmd_keymap(
  'x',
  '<M-k>',
  ":silent! m '<-2<CR>gv=gv",
  { desc = 'Move selection up' }
)

-- Neovim Config Operations ---------------------------------------------------
vim.keymap.set('n', '<leader>cn', function()
  local config_lua_path = os_mod.normalize_os_path(vim.fn.stdpath 'config')
    .. '/'
  file.prompt_path('New Lua config: ', config_lua_path, nil, function(path)
    if path == '' then return end
    if not path:match '%.lua$' then path = path .. '.lua' end
    file.create_file(path)
  end)
end, { desc = '[C]onfig [N]ew' })

vim.keymap.set(
  'n',
  '<leader>cs',
  function()
    require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
  end,
  { desc = '[C]onfig [S]earch files' }
)

vim.keymap.set(
  'n',
  '<leader>cg',
  function()
    require('telescope.builtin').live_grep {
      cwd = vim.fn.stdpath 'config',
      prompt_title = 'Live grep in neovim config',
    }
  end,
  { desc = '[C]onfig [G]rep' }
)
