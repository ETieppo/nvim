local plugins = require 'deps.plugins'
local prompt_bar = require 'layout.cmdline.prompt_bar'
local art = require 'layout.snacks.dash_art'
math.randomseed(os.time())

plugins.record {
  'folke/snacks.nvim',
  opts = {
    animate = { enabled = true },
    bigfile = { enabled = true },
    bufdelete = { enabled = true },
    debug = { enabled = true },
    indent = { enabled = true },
    input = {
      enabled = true,
      icon_pos = false,
      prompt_pos = 'left',
      expand = false,
      win = vim.tbl_extend('force', prompt_bar.window_config, {
        width = 0,
        wo = { winhighlight = prompt_bar.window_highlight },
      }),
    },
    scroll = { enabled = true },
    image = {
      enabled = true,
      bo = { bufhidden = 'wipe' },
    },
    dashboard = {
      row = 0,
      col = 0,
      sections = function(dashboard)
        dashboard.opts.width = vim.o.columns
        return {
          gap = 1,
          art(),
          {
            align = 'center',
            height = math.floor(vim.o.lines * 0.10),
            section = 'startup',
          },
        }
      end,
    },
  },
}
