local plugins = require 'deps.plugins'

local COLLECTOR_AUGROUP_NAME = 'useless-wpm-collector'
local TYPING_MODE_ENTER_PATTERN = '*:[iR]*'

vim.api.nvim_create_autocmd('ModeChanged', {
  desc = 'Start collecting the typing speed',
  group = vim.api.nvim_create_augroup(COLLECTOR_AUGROUP_NAME, { clear = true }),
  pattern = TYPING_MODE_ENTER_PATTERN,
  callback = function() require('useless.wpm.collector').start() end,
})

---@module 'lazy'
---@type LazySpec
plugins.record {
  'akinsho/bufferline.nvim',
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.custom_areas = opts.options.custom_areas or {}
    opts.options.custom_areas.right = function()
      return require('useless.wpm.metric').get_bufferline_sections()
    end
    return opts
  end,
}
