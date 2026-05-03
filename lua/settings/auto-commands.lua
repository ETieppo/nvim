vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- When neo-tree is the only window it expands to fill the screen; restore its
-- configured width as soon as a real file is opened.
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = vim.api.nvim_create_augroup('neo_tree_width_restore', { clear = true }),
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == 'neo-tree' or vim.bo[buf].buftype ~= '' then return end
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(w)
        and vim.api.nvim_win_get_config(w).relative == ''
        and vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree'
        and vim.api.nvim_win_get_width(w) > 30
      then
        vim.api.nvim_win_set_width(w, 26)
        break
      end
    end
  end,
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
