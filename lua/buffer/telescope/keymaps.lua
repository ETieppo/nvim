local ripgrep = require 'utils.ripgrep'

vim.keymap.set(
  'n',
  '<leader>sh',
  function() require('telescope.builtin').help_tags() end,
  { desc = '[S]earch [H]elp' }
)
vim.keymap.set(
  'n',
  '<leader>sk',
  function() require('telescope.builtin').keymaps() end,
  { desc = '[S]earch [K]eymaps' }
)
vim.keymap.set(
  'n',
  '<leader>ss',
  function() require('telescope.builtin').builtin() end,
  { desc = '[S]earch [S]elect Telescope' }
)
vim.keymap.set(
  'n',
  '<leader>sg',
  function() require('telescope.builtin').live_grep() end,
  { desc = '[S]earch by [G]rep' }
)
vim.keymap.set(
  'n',
  '<leader>sd',
  function() require('telescope.builtin').diagnostics() end,
  { desc = '[S]earch [D]iagnostics' }
)
vim.keymap.set(
  'n',
  '<leader>sc',
  function() require('telescope.builtin').commands() end,
  { desc = '[S]earch [C]ommands' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>sw',
  function() require('telescope.builtin').grep_string() end,
  { desc = '[S]earch current [W]ord' }
)
vim.keymap.set(
  'n',
  '<leader><leader>',
  function() require('telescope.builtin').find_files() end,
  { desc = 'Search Files' }
)

vim.keymap.set(
  'n',
  '<leader>a',
  function()
    require('telescope.builtin').find_files {
      prompt_title = 'Find All Files',
      find_command = ripgrep.build_command(
        { '--files', '--color=never', '--no-ignore' },
        { '.git/' }
      ),
    }
  end,
  { desc = '[A]ll Files' }
)

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    require('telescope.builtin').current_buffer_fuzzy_find(
      require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      }
    )
  end,
  { desc = '[/] Fuzzily search in current buffer' }
)

vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    require('telescope.builtin').live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)
