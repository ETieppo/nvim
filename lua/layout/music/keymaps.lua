local async = require 'utils.async'
local auth = require 'layout.music.auth'
local credentials = require 'layout.music.credentials'
local deps_command = require 'deps.commands'
local library = require 'layout.music.library'
local picker = require 'layout.music.picker'
local player = require 'layout.music.player'
local profile = require 'deps.profile'

if profile.is_max_profile() then
  vim.keymap.set('n', '<leader>mn', player.next, { desc = '[M]usic [N]ext' })
  vim.keymap.set(
    'n',
    '<leader>mp',
    player.previous,
    { desc = '[M]usic [P]revious' }
  )
  vim.keymap.set(
    'n',
    '<leader>mb',
    player.restart,
    { desc = '[M]usic [B]ack to start' }
  )
  vim.keymap.set(
    'n',
    '<leader>mm',
    player.toggle_pause,
    { desc = '[M]usic [M]ute (pause)' }
  )
  vim.keymap.set(
    'n',
    '<leader>mts',
    player.toggle_shuffle,
    { desc = '[M]usic [T]oggle [S]huffle' }
  )
  vim.keymap.set(
    'n',
    '<leader>ms',
    picker.open_search,
    { desc = '[M]usic [S]earch' }
  )
  vim.keymap.set(
    'n',
    '<leader>ml',
    picker.open_library,
    { desc = '[M]usic [L]ibrary' }
  )
  vim.keymap.set(
    'n',
    '<leader>mc',
    picker.open_catalog,
    { desc = '[M]usic [C]atalog' }
  )

  deps_command.create_deps_user_command {
    name = 'Music',
    desc = 'Manage the music library and Spotify access',
    subcommands = {
      sync = {
        short = 's',
        run = function() async.run(library.sync, true) end,
      },
      login = {
        short = 'l',
        run = function() async.run(auth.log_in_again) end,
      },
      credentials = {
        short = 'c',
        run = function() async.run(credentials.replace) end,
      },
    },
  }
end
