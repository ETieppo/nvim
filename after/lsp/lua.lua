local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'lua',
      os = {
        archlinux = 'pacman -S lua',
        windows = 'scoop install main/lua',
        macos = 'brew install lua',
      },
    },
    {
      cmd = 'lua-language-server',
      os = {
        macos = 'brew install lua-language-server',
        archlinux = 'pacman -S lua-language-server',
        windows = 'scoop install main/lua-language-server',
      },
    },
  },
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'stylua',
}

return {
  cmd = { 'lua-language-server' },
  filetypes = { lang_name },
  root_markers = { '.git', '.stylua.toml' },
}
