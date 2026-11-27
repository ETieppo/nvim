local plugins = require 'deps.plugins'

plugins.record {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      function()
        require('conform').format { async = true, lsp_fallback = true }
      end,
      mode = '',
      desc = '[F]ile [F]ormat',
    },
  },
  opts = function()
    local formatters = require('core.formatter.registry').get_formatters()
    return {
      notify_on_error = false,
      format_on_save = nil,
      formatters = formatters.configs,
      formatters_by_ft = formatters.linkers,
    }
  end,
}
