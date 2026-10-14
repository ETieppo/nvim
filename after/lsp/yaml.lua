local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'utils.lang'

lang_mod.record_lang_deps {
  lang = lang_name,
  short = "yml",
  deps = {
    {
      cmd = "yaml-language-server",
      install_command = "bun add -g yaml-language-server"
    }
  }
}

return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { lang_name, 'yml' },
  root_markers = {}
}
