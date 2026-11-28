local profile = require 'deps.profile'

if profile.is_max_profile() then
  vim.keymap.set(
    'n',
    '<leader>mn',
    function() require('layout.music.player').next() end,
    { desc = '[M]usic [N]ext' }
  )
  vim.keymap.set(
    'n',
    '<leader>mp',
    function() require('layout.music.player').previous() end,
    { desc = '[M]usic [P]revious' }
  )
  vim.keymap.set(
    'n',
    '<leader>mb',
    function() require('layout.music.player').restart() end,
    { desc = '[M]usic [B]ack to start' }
  )
  vim.keymap.set(
    'n',
    '<leader>mm',
    function() require('layout.music.player').toggle_pause() end,
    { desc = '[M]usic [M]ute (pause)' }
  )
  vim.keymap.set(
    'n',
    '<leader>mts',
    function() require('layout.music.player').toggle_shuffle() end,
    { desc = '[M]usic [T]oggle [S]huffle' }
  )
  vim.keymap.set(
    'n',
    '<leader>ms',
    function() require('layout.music.picker').open_search() end,
    { desc = '[M]usic [S]earch' }
  )
  vim.keymap.set(
    'n',
    '<leader>ml',
    function() require('layout.music.picker').open_library() end,
    { desc = '[M]usic [L]ibrary' }
  )
  vim.keymap.set(
    'n',
    '<leader>mc',
    function() require('layout.music.picker').open_catalog() end,
    { desc = '[M]usic [C]atalog' }
  )
end
