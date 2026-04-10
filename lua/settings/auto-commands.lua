vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local bt = vim.bo.buftype
    local ft = vim.bo.filetype
    local excluded_ft = { 'neo-tree', 'minimap', 'neominimap', 'aerial', 'dashboard' }
    local excluded_bt = { 'terminal', 'nofile', 'prompt', 'quickfix' }
    local is_excluded_ft = vim.tbl_contains(excluded_ft, ft)
    local is_excluded_bt = vim.tbl_contains(excluded_bt, bt)

    if is_excluded_ft or is_excluded_bt then
      vim.opt_local.statuscolumn = ''
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    else
      vim.opt_local.statuscolumn = '%s%{v:lnum} %{v:relnum} '
      vim.opt_local.number = true
      vim.opt_local.relativenumber = true
    end
  end,
})
