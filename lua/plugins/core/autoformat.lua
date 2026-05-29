return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>ff',
      function() require('conform').format { async = true, lsp_fallback = true } end,
      mode = '',
      desc = '[F]ormat [F]ile',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = nil,

    formatters_by_ft = {
      lua = { 'stylua' },
      markdown = { 'markdownlint-cli2' },
      rust = { 'rustfmt' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      html = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      json = { 'prettier' },
      toml = { 'taplo' },
    },
  },
}
