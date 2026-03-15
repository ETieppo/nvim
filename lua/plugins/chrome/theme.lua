return {
  -- 'uhs-robert/oasis.nvim',
  'craftzdog/solarized-osaka.nvim',
  -- 'DonJulve/NeoCyberVim',
  priority = 1000,
  config = function()
    --@diagnostic disable-next-line: missing-fields
    -- vim.cmd.colorscheme 'moonfly'
    vim.cmd.colorscheme 'solarized-osaka'
    -- vim.cmd.colorscheme 'NeoCyberVim-dark'

    vim.o.background = 'dark'
  end,
}
