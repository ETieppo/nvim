local plugins = require 'deps.plugins'
local os_mod = require 'deps.sys'

---@param linter lint.Linter
---@return boolean
local function has_linter_executable(linter)
  local cmd = linter.cmd
  if type(cmd) == 'function' then cmd = cmd() end
  return os_mod.has_executable(cmd)
end

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
      local builtin_linter = lint.linters[linter_name]
      lint.linters[linter_name] = type(builtin_linter) == 'table'
          and vim.tbl_extend('force', builtin_linter, linter_config)
        or linter_config
    end

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint(nil, { filter = has_linter_executable })
        end
      end,
    })
  end,
}
