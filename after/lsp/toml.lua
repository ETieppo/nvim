local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  deps = {
    { cmd = 'taplo' },
  },
}

lang_mod.record_fmt {
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
