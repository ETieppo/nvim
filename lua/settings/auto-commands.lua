vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Keep neo-tree as a fixed sidebar when the last real buffer is closed
-- - closing a real file (last one): creates empty placeholder, keeps sidebar
-- - closing the empty placeholder: quits neovim
vim.api.nvim_create_autocmd('WinClosed', {
  callback = function(event)
    local closed_win = tonumber(event.match)
    if not vim.api.nvim_win_is_valid(closed_win) then return end

    local closed_buf = vim.api.nvim_win_get_buf(closed_win)
    local ft = vim.bo[closed_buf].filetype
    if ft == 'neo-tree' then return end

    local is_unnamed = vim.api.nvim_buf_get_name(closed_buf) == ''

    local neo_win = nil
    local other_real_wins = 0
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if w == closed_win then goto continue end
      if not vim.api.nvim_win_is_valid(w) then goto continue end
      local buf = vim.api.nvim_win_get_buf(w)
      if vim.bo[buf].filetype == 'neo-tree' then
        neo_win = w
      else
        other_real_wins = other_real_wins + 1
      end
      ::continue::
    end

    if other_real_wins == 0 and neo_win then
      if is_unnamed then
        vim.schedule(function() vim.cmd('qa') end)
      else
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(neo_win) then
            vim.api.nvim_set_current_win(neo_win)
            vim.cmd('rightbelow vsplit | enew')
            vim.api.nvim_win_set_width(neo_win, 26)
          end
        end)
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
