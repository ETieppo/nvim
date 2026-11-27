local plugins = require 'deps.plugins'

---@module 'lazy'
---@type LazySpec
plugins.record {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    local linters = require('core.linter.registry').get_linters()
    lint.linters_by_ft = linters.linkers
    for linter_name, linter_config in pairs(linters.configs) do
      lint.linters[linter_name] = linter_config
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then lint.try_lint() end
      end,
    })
  end,
}
