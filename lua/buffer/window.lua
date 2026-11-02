local DASHBOARD_FILETYPE = 'snacks_dashboard'
local DASHBOARD_CLOSING_FILETYPES = { 'neo-tree', 'dbui', 'dbout' }
local NUMBERED_STATUSCOLUMN = '%{v:lnum} %{v:relnum}%=%s'
local UNNUMBERED_FILETYPES =
  { 'neo-tree', 'minimap', 'neominimap', 'aerial', 'dashboard' }
local UNNUMBERED_BUFTYPES = { 'terminal', 'nofile', 'prompt', 'quickfix' }
local WINDOW_FOCUS_DIRECTIONS = {
  h = 'left',
  j = 'lower',
  k = 'upper',
  l = 'right',
}

local M = {}

function M.close_dashboard()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buffer)
      and vim.bo[buffer].filetype == DASHBOARD_FILETYPE
    then
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
  end
end

---@return boolean
local function should_show_line_numbers()
  return not vim.list_contains(UNNUMBERED_FILETYPES, vim.bo.filetype)
    and not vim.list_contains(UNNUMBERED_BUFTYPES, vim.bo.buftype)
end

local function apply_line_numbers_to_current_window()
  local show_line_numbers = should_show_line_numbers()
  vim.opt_local.statuscolumn = show_line_numbers and NUMBERED_STATUSCOLUMN or ''
  vim.opt_local.number = show_line_numbers
  vim.opt_local.relativenumber = show_line_numbers
end

for key, direction in pairs(WINDOW_FOCUS_DIRECTIONS) do
  vim.keymap.set(
    'n',
    '<C-' .. key .. '>',
    '<C-w><C-' .. key .. '>',
    { desc = 'Focus ' .. direction .. ' window' }
  )
end

vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Show line numbers only in regular windows',
  callback = apply_line_numbers_to_current_window,
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close the dashboard when a side panel opens',
  pattern = DASHBOARD_CLOSING_FILETYPES,
  callback = function() vim.schedule(M.close_dashboard) end,
})

return M
