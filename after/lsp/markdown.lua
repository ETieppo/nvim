local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_linter {
  lang = lang_name,
  linter = 'markdownlint-cli2'
}

lang_mod.record_lang_deps {
  lang = lang_name,
  short = "md",
  deps = {
    {
      cmd = "markdownlint-cli2",
      os = {
        archlinux = "pacman -S markdownlint-cli2",
        macos = "brew install markdownlint-cli2"
      }
    }
  }
}

return {
  cmd = {},
  filetypes = { "markdown" }
}
