local lang_deps = require 'core.lang_registry'
local docs= require 'core.docs'
local treesitter = require 'core.treesitter'
local fmt = require 'core.fmt'
local lsp = require 'core.lsp'
local lang_name = require('utils.helpers').get_this_filename()

docs.docs_ignore()
treesitter.treesitter_ignore()

fmt.record_fmt {
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

lang_deps.record_lang_deps {
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

lsp.record_lsp {
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
  on_init = lsp.convert_completion_kind_names_on_init,
}
