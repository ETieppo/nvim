local async = require 'utils.async'
local deps_command = require 'deps.commands'
local profile = require 'deps.profile'

if profile.is_max_profile() then
  deps_command.create_deps_user_command {
    name = 'Music',
    desc = 'Manage the music library and Spotify access',
    subcommands = {
      sync = {
        short = 's',
        run = function() async.run(require('layout.music.library').sync, true) end,
      },
      login = {
        short = 'l',
        run = function() async.run(require('layout.music.auth').log_in_again) end,
      },
      credentials = {
        short = 'c',
        run = function() async.run(require('layout.music.credentials').replace) end,
      },
    },
  }
end
