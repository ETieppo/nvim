local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'taplo',
      os = {
        archlinux = 'sudo pacman -S taplo-cli',
        macos = 'brew install taplo',
        windows = 'scoop install taplo',
      },
    },
  },
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'taplo',
}

return {
  cmd = {
    'taplo',
    'lsp',
    'stdio',
  },
  filetypes = { lang_name },
  toml = {
    root_markers = {
      'Cargo.toml',
      '.taplo.toml',
      'taplo.toml',
      '.git',
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
}
