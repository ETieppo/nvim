local DASHBOARD_FILETYPE = 'snacks_dashboard'

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

return M
