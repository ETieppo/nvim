local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  tree_sitter_name = 'dockerfile',
  deps = {
    {
      cmd = 'docker-langserver',
      install_command = 'bun add -g dockerfile-language-server-nodejs',
    },
    {
      cmd = 'docker',
      os = {
        archlinux = 'sudo pacman -S docker --nocomfirm',
        macos = 'brew install docker',
        windows = 'scoop bucket add main ; scoop install main/docker',
      },
    },
  },
}

return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'Dockerfile', 'docker' },
}
