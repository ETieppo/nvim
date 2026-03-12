return {
  {
    'rcarriga/nvim-notify',
    lazy = false,
    config = function()
      local notify = require 'notify'
      notify.setup {
        stages = 'fade',
        timeout = 2500,
        render = 'wrapped-compact',
      }
      vim.notify = notify
    end,
  },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      messages = { enabled = true },
      notify = {
        enabled = true,
        view = 'notify',
      },
      cmdline = { enabled = true },
      popupmenu = { enabled = true },
      presets = {
        long_message_to_split = true,
        command_palette = true,
      },
    },
  },
}
