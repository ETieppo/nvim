local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'qml-language-server',
      os = {
        archlinux = "yay -S qml-language-server-git"
      }
    },
    {
      cmd = "qmlls6",
      os = {
        archlinux = "sudo pacman -S qt6-declarative"
      }
    }
  }
}

return {
  cmd = { 'qml-language-server' },
  filetypes = { 'qml' },
  root_markers = { { "qmldir", "shell.qml" }, ".git" },
}
