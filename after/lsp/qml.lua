local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

require('utils.os_mod').add_to_path '/usr/lib/qt6/bin'

lang_mod.record_lang_deps {
  tree_sitter_name = { 'qmljs' },
  deps = {
    { cmd = 'qmlls6', os = { archlinux = 'qt6-languageserver' } },
    { cmd = 'qmlls6', os = { archlinux = 'qt6-declarative' } },
    { cmd = 'qmlformat', os = { archlinux = 'qt6-declarative' } },
  },
}

return {
  cmd = { 'qmlls6' },
  filetypes = { lang_name },
  root_markers = {},
}
