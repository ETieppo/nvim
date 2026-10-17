local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'tl',
  deps = {
    {
      cmd = 'luarocks',
      os = {
        archlinux = 'pacman -S luarocks',
        macos = 'brew install luarocks',
        windows = 'scoop install luarocks',
      },
    },
    {
      cmd = 'tl',
      os = {
        unix = 'sudo luarocks install tl',
        windows = 'luarocks install tl',
      },
    },
    {
      cmd = 'cyan',
      os = {
        unix = 'sudo luarocks install cyan',
        windows = 'luarocks install cyan',
      },
    },
    {
      cmd = 'teal-language-server',
      os = {
        unix = 'sudo luarocks install teal-language-server',
        windows = 'luarocks install teal-language-server',
      },
    },
  },
}

return {
  cmd = { 'teal-language-server', '--verbose=false', '--log-mode=none' },
  filetypes = { lang_name },
  root_markers = { '.git', 'tlconfig.lua' },
}
