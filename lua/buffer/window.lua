local DASHBOARD_FILETYPE = 'snacks_dashboard'
local DASHBOARD_CLOSING_FILETYPES = {
  'neo-tree',
  'dbui',
  'dbout',
}
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

for key, direction in pairs(WINDOW_FOCUS_DIRECTIONS) do
  vim.keymap.set(
    'n',
    '<M-D-' .. key .. '>',
    '<C-w>' .. key,
    { desc = 'Focus ' .. direction .. ' window' }
  )
end

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close the dashboard when a side panel opens',
  pattern = DASHBOARD_CLOSING_FILETYPES,
  callback = function() vim.schedule(M.close_dashboard) end,
})

return M
