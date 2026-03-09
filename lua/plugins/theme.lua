return {
  -- 'bluz71/vim-moonfly-colors',
  'tiagovla/tokyodark.nvim',
  priority = 1000,
  config = function()
    --@diagnostic disable-next-line: missing-fields
    -- vim.cmd.colorscheme 'moonfly'
    vim.cmd.colorscheme 'tokyodark'
  end,
}
