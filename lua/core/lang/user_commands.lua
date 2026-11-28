local deps_command = require 'deps.commands'
local lang_deps = require 'deps.language'

deps_command.create_deps_user_command {
  name = 'Lang',
  desc = 'Manage the dependencies of a language',
  target_name = 'language',
  subcommands = {
    install = {
      short = 'i',
      run = lang_deps.install_lang_deps,
    },
  },
}
