local plugins = require 'deps.plugins'
local ripgrep = require 'utils.ripgrep'
---@type table<string, boolean>
local disabled_arrow_mappings = {}

plugins.record {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
  },
  enabled = true,
  event = 'VimEnter',
  config = function()
    require('telescope').setup {
      defaults = {
        mappings = {
          i = vim.deepcopy(disabled_arrow_mappings),
          n = vim.deepcopy(disabled_arrow_mappings),
        },
        vimgrep_arguments = ripgrep.build_command {
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
        },
      },
      pickers = {
        find_files = {
          find_command = ripgrep.build_command { '--files' },
        },
      },
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end,
}
