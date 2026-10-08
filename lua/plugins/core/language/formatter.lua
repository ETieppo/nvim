local formatters = require('utils.lang').formatters

return {
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
      desc = '[F]ormat [F]ile',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = nil,
    formatters = formatters.configs,
    formatters_by_ft = formatters.linkers
  },
}
