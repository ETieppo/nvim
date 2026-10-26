local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  short = 'tl',
  deps = {
    { cmd = 'luarocks' },
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
    {
      cmd = 'ceru',
      os = {
        unix = 'sudo luarocks install cerulean',
        windows = 'luarocks install cerulean',
      },
    },
  },
}

lang_mod.record_fmt {
  formatter = 'cerulean',
  config = {
    command = 'ceru',
    stdin = false,
    args = {},
  },
}

return {
  cmd = { 'teal-language-server', '--verbose=false', '--log-mode=none' },
  filetypes = { lang_name },
  root_markers = { '.git', 'tlconfig.lua' },
}
