local buffer = require 'buffer.buffer'

local M = {}
M.has_open_dbui = false

---@return integer
local function find_fallback_buffer()
  return buffer.find_most_recent_listed_buffer(buffer.is_database_buffer)
    or vim.api.nvim_create_buf(true, false)
end

local function close_database_buffers()
  ---@type integer|nil
  local fallback
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and buffer.is_database_buffer(buf) then
      local is_result = vim.bo[buf].filetype == 'dbout'

      if vim.bo[buf].modified then
        pcall(
          vim.api.nvim_buf_call,
          buf,
          function() vim.cmd 'silent noautocmd write' end
        )
      end

      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if not (is_result and pcall(vim.api.nvim_win_close, win, false)) then
          fallback = fallback or find_fallback_buffer()
          vim.api.nvim_win_set_buf(win, fallback)
        end
      end

      if not pcall(vim.api.nvim_buf_delete, buf, {}) then
        vim.notify(
          'Could not close ' .. vim.api.nvim_buf_get_name(buf),
          vim.log.levels.WARN,
          { title = 'DBUI' }
        )
      end
    end
  end
  vim.cmd 'DBUIClose'
end

---@return integer|nil
local function find_drawer_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'dbui' then
      return win
    end
  end
end

---@return boolean
function M.focus()
  local win = find_drawer_window()
  if not win then return false end
  vim.api.nvim_set_current_win(win)
  return true
end

function M.toggle()
  if find_drawer_window() then return close_database_buffers() end
  vim.cmd 'Neotree close'
  vim.cmd 'DBUI'
end

return M
