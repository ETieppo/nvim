local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_linter {
  lang = lang_name,
  linter = 'markdownlint-cli2',
}

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'md',
  deps = {
    {
      cmd = 'markdownlint-cli2',
      os = {
        archlinux = 'pacman -S markdownlint-cli2',
        macos = 'brew install markdownlint-cli2',
      },
    },
    {
      cmd = 'marksman',
      os = {
        archlinux = 'pacman -S marksman',
        macos = 'brew install marksman',
        windows = 'scoop install marksman',
      },
    },
  },
}

return {
  cmd = { 'marksman', 'server', '--verbose', '0' },
  filetypes = { 'markdown', 'markdown.mdx' },
  root_markers = { '.git', '.marksman.toml' },
}
