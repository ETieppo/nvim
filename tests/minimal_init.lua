local config_path =
  vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local plenary_path = vim.fn.stdpath 'data' .. '/lazy/plenary.nvim'

vim.opt.rtp:prepend(config_path)
vim.opt.rtp:prepend(plenary_path)
vim.cmd.runtime 'plugin/plenary.vim'
