require('utils.lang_deps').register_lang_deps({
  lang = 'lua',
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
})

return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.git', '.stylua.toml' },
}
