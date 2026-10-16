local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  tree_sitter_name = { "qmljs" },
  deps = {
    {
      cmd = "qmlls6",
      os = {
        archlinux = "sudo pacman -S qt6-declarative qt6-languageserver"
      }
    },
    {
      cmd = "qmlformat",
      os = {
        archlinux = "pacman -S qt6-tools && echo 'export PATH=\"/usr/lib/qt6/bin:$PATH\"' >> ~/.zshrc"
      }
    }
  }
}

return {
  cmd = { 'qmlls6' },
  filetypes = { lang_name },
  root_markers = {}
}
