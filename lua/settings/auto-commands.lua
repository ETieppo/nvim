vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local _sidebar_augroup = vim.api.nvim_create_augroup('neo_tree_sidebar_guard', { clear = true })

local function find_neo_win()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if not vim.api.nvim_win_is_valid(w) then goto continue end
    if vim.api.nvim_win_get_config(w).relative ~= '' then goto continue end
    if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == 'neo-tree' then return w end
    ::continue::
  end
end

local function count_real_wins()
  local n = 0
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if not vim.api.nvim_win_is_valid(w) then goto continue end
    if vim.api.nvim_win_get_config(w).relative ~= '' then goto continue end
    local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    if ft ~= 'neo-tree' then n = n + 1 end
    ::continue::
  end
  return n
end

-- Keep neo-tree as a fixed sidebar when the last real buffer is closed:
-- - closing a real file (last one) → creates empty placeholder, keeps sidebar
-- - closing the empty placeholder  → quits neovim
vim.api.nvim_create_autocmd('WinClosed', {
  group = _sidebar_augroup,
  callback = function(event)
    local closed_win = tonumber(event.match)

    -- WinClosed fires after the window is gone; try to read buffer info while
    -- it might still be briefly accessible.
    local closed_is_placeholder = false
    if vim.api.nvim_win_is_valid(closed_win) then
      local buf = vim.api.nvim_win_get_buf(closed_win)
      if vim.bo[buf].filetype ~= 'neo-tree' then
        closed_is_placeholder = vim.api.nvim_buf_get_name(buf) == ''
      end
    end

    -- defer_fn gives neo-tree time to finish its own layout handling before we act
    vim.defer_fn(function()
      local neo_win = find_neo_win()
      if not neo_win or count_real_wins() > 0 then return end

      if closed_is_placeholder then
        vim.cmd('qa')
      else
        vim.api.nvim_set_current_win(neo_win)
        vim.cmd('rightbelow vsplit | enew')
        vim.api.nvim_win_set_width(neo_win, 26)
      end
    end, 50)
  end,
})

-- Fix neo-tree width after it expanded because it was the only window
vim.api.nvim_create_autocmd('BufWinEnter', {
  group = _sidebar_augroup,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].filetype == 'neo-tree' or vim.bo[buf].buftype ~= '' then return end
    local neo_win = find_neo_win()
    if neo_win and vim.api.nvim_win_get_width(neo_win) > 30 then
      vim.api.nvim_win_set_width(neo_win, 26)
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
