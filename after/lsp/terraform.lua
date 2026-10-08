local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'tf',
  deps = {
    {
      cmd = 'terraform-ls',
      os = {
        macos = 'brew install terraform-ls',
        archlinux = 'yay -S terraform-ls',
        windows = 'scoop bucket add main ; scoop install main/terraform-ls',
      },
    },
    {
      cmd = 'terraform',
      os = {
        archlinux = 'sudo pacman -S terraform',
        macos = 'brew tap hashicorp/tap && brew install hashicorp/tap/terraform && brew upgrade hashicorp/tap/terraform',
        windows = 'scoop install main/terraform',
      },
    },
  },
}

return {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { lang_name, 'tf' },
}
