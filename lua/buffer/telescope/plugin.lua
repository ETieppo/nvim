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
    local preview_utils = require 'telescope.previewers.utils'

    local function attach_media(filepath, bufnr)
      if not Snacks.image.supports_file(filepath) then return false end
      Snacks.image.buf.attach(bufnr, { src = filepath })
      return true
    end

    local function preview_known_filetype(filepath, bufnr)
      return not attach_media(filepath, bufnr)
    end

    local function preview_binary(filepath, bufnr, opts)
      if attach_media(filepath, bufnr) then return end
      preview_utils.set_preview_message(
        bufnr,
        opts.winid,
        'Binary cannot be previewed'
      )
    end

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
        preview = {
          mime_hook = preview_binary,
          filetype_hook = preview_known_filetype,
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

    vim.api.nvim_create_autocmd('User', {
      pattern = 'TelescopePreviewerLoaded',
      callback = function(event)
        if event.data.filetype ~= 'markdown' then return end
        vim.bo.filetype = 'markdown'
      end,
    })
  end,
}
