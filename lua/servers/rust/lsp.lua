local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  deps = { { install_command = 'rustup component add rust-analyzer' } },
  cmd = { 'rust-analyzer' },
  filetypes = { lang_name },
  root_markers = {
    'Cargo.toml',
    '.git',
  },
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
