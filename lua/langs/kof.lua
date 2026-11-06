local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.docs_ignore()
lang_mod.treesitter_ignore()

lang_mod.record_fmt {
  formatter = 'kof_fmt',
  config = {
    command = 'kof',
    args = {
      'fmt',
      '$FILENAME',
      '-w',
    },
    stdin = false,
  },
}

lang_mod.record_lang_deps {
  deps = {
    {
      cmd = 'kfvm',
      os = {
        unix = 'curl -fsSL https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.sh | sh',
        windows = 'irm https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.ps1 | iex',
      },
    },
    {
      cmd = 'kof',
      install_command = 'kfvm u lts',
    },
  },
}

vim.filetype.add {
  extension = {
    kf = 'kof',
    kof = 'kof',
  },
}

---@type vim.lsp.Config
return {
  cmd = {
    'kof',
    'lsp',
  },
  filetypes = { lang_name },
  root_markers = {
    'kofdeps',
    'kof.toml',
    '.git',
  },
  on_init = lang_mod.convert_completion_kind_names_on_init,
}
