local plugins = require 'deps.plugins'

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
  lazy = true,
  init = function()
    local native_select = vim.ui.select
    local function select_after_loading_telescope(...)
      require('lazy').load { plugins = { 'telescope.nvim' } }
      if vim.ui.select == select_after_loading_telescope then
        rawset(vim.ui, 'select', native_select)
      end
      return vim.ui.select(...)
    end
    rawset(vim.ui, 'select', select_after_loading_telescope)
  end,
  config = function()
    local ripgrep = require 'utils.ripgrep'
    require('telescope').setup {
      defaults = {
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
