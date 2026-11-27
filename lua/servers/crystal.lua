local toolchain = require 'core.lang.registry'
local treesitter = require 'core.treesitter.registry'
local fmt = require 'core.formatter.registry'
local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_filename()

treesitter.record_treesitter(lang_name, {
  url = 'https://github.com/crystal-lang-tools/tree-sitter-crystal',
  revision = '50ca9e6fcfb16a2cbcad59203cfd8ad650e25c49',
  queries = 'queries/nvim',
})

toolchain.record_toolchain {
  short = 'cr',
  deps = { { cmd = 'crystal' } },
}

fmt.record_fmt { formatter = 'crystal' }

dap.record_dap { adapter = 'lldb' }

lsp.record_lsp {
  cmd = { 'crystalline' },
  filetypes = { lang_name },
  root_markers = { 'shard.yml', '.git' },
}
