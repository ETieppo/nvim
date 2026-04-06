return {
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        opts = {
          stages = 'fade',
          timeout = 1500,
          render = 'wrapped-compact',
        },
        config = function(_, opts)
          local notify = require 'notify'
          notify.setup(opts)
          vim.notify = notify
        end,
      },
    },
    opts = {
      messages = { enabled = true },
      notify = {
        enabled = true,
        view = 'notify',
      },
      popupmenu = { enabled = true },
      lsp = {
        progress = { enabled = false },
        message = { enabled = false },
      },
      presets = {
        long_message_to_split = true,
        command_palette = true,
      },
      cmdline = {
        enabled = true,
        format = {
          cmdline = {
            pattern = '^:',
            icon = ' ',
            lang = 'vim',
            conceal = false,
            title = '',
          },
          search_down = {
            kind = 'search',
            pattern = '^/',
            icon = '  ',
            lang = 'regex',
            conceal = false,
            title = '',
          },
          search_up = {
            kind = 'search',
            pattern = '^%?',
            icon = '  ',
            lang = 'regex',
            conceal = false,
            title = '',
          },
          filter = {
            pattern = '^:%s*!',
            icon = '$ ',
            lang = 'bash',
            conceal = false,
            title = '',
          },
          lua = {
            pattern = {
              '^:%s*lua%s+',
              '^:%s*lua%s*=%s*',
              '^:%s*=%s*',
            },
            icon = ' ',
            lang = 'lua',
            conceal = false,
            title = '',
          },
          help = {
            pattern = '^:%s*he?l?p?%s+',
            icon = ' ',
            conceal = false,
            title = '',
          },
          input = {
            view = 'cmdline_input',
            icon = '󰥻 ',
            title = '',
          },
        },
      },
    },
  },
}
