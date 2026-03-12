return {
  -- 'uhs-robert/oasis.nvim',
  'craftzdog/solarized-osaka.nvim',
  -- 'DonJulve/NeoCyberVim',
  priority = 1000,
  config = function()
    --@diagnostic disable-next-line: missing-fields
    -- vim.cmd.colorscheme 'moonfly'
    vim.cmd.colorscheme 'solarized-osaka'
    vim.o.background = 'dark'
  end,
}
