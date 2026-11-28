local toolchain = require 'core.lang.registry'
local treesitter = require 'core.treesitter.registry'
local fmt = require 'core.formatter.registry'
local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lint = require 'core.linter.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

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

lint.record_linter {
  linter = 'ameba',
  deps = {
    {
      os = {
        macos = 'brew tap crystal-ameba/ameba && brew trust --formula crystal-ameba/ameba/ameba && brew install crystal-ameba/ameba/ameba',
      },
    },
  },
  config = {
    name = 'ameba',
    cmd = 'ameba',
    stdin = false,
    append_fname = true,
    args = { '--format', 'json' },
    ignore_exitcode = true,
    parser = function(output)
      return require('lint.linters.ameba').parser(output)
    end,
  },
}

lsp.record_lsp {
  cmd = { 'crystalline' },
  filetypes = { lang_name },
  root_markers = { 'shard.yml', '.git' },
}

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup(
    'crystal-commentstring',
    { clear = true }
  ),
  pattern = lang_name,
  callback = function(args) vim.bo[args.buf].commentstring = '# %s' end,
})
