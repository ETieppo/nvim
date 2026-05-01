---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    local selene_config = vim.fn.stdpath 'config' .. '/selene.toml'
    require('lint').linters.selene.args = { '--display-style', 'json', '--config', selene_config, '-' }

    lint.linters_by_ft = {
      markdown = { 'markdownlint-cli2' },
      c = {},
      cpp = { 'cpplint' },
      kotlin = { 'ktlint' },
      lua = { 'selene' },
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
