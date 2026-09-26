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

    formatters = {
      kof_fmt = {
        command = 'kof',
        args = { 'fmt', '$FILENAME', '-w' },
        stdin = false,
      },
    },

    formatters_by_ft = {
      kof = { 'kof_fmt' },
      lua = { 'stylua' },
      markdown = { 'markdownlint-cli2' },
      rust = { 'rustfmt' },
      javascript = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      typescript = { 'prettierdd', 'prettierd' },
      typescriptreact = { 'prettierd' },
      html = { 'prettierd' },
      htmlangular = { 'prettierd' },
      css = { 'prettierd' },
      scss = { 'prettierd' },
      json = { 'prettierd' },
      toml = { 'taplo' },
      python = { 'black' },
    },
  },
}
