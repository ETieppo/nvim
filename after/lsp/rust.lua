local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_test_adapter {
  'mrcjkb/rustaceanvim',
  module = 'rustaceanvim.neotest',
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'rustfmt',
}

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'rs',
  deps = {
    {
      cmd = 'rustup',
      os = {
        unix = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
        windows = 'scoop install rustup',
      },
    },
    {
      cmd = 'cargo',
      install_command = 'rustup toolchain install stable',
    },
    {
      cmd = 'rust-analyzer',
      install_command = 'rustup component add rust-analyzer',
    },
  },
}

return {
  cmd = { vim.fn.expand 'rust-analyzer' },
  filetypes = { lang_name },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'check',
      },
      procMacro = {
        enable = true,
      },
      cargo = {
        buildScripts = { enable = true },
        targetDir = true,
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
