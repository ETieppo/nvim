local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  short = 'tf',
  deps = {
    { cmd = 'terraform-ls' },
    {
      cmd = 'terraform',
      os = { macos = 'hashicorp/tap/terraform' },
    },
  },
}

return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { lang_name, 'tf' },
}
