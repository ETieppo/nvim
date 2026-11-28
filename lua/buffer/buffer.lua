local DatabaseFiletypeEnum =
  require('layout.database_manager.enums').DatabaseFiletypeEnum

local M = {}

---@param is_excluded fun(buffer: integer): boolean
---@return integer|nil
function M.find_most_recent_listed_buffer(is_excluded)
  local most_recent_buffer, most_recent_use = nil, -1
  for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
    if info.lastused > most_recent_use and not is_excluded(info.bufnr) then
      most_recent_buffer, most_recent_use = info.bufnr, info.lastused
    end
  end
  return most_recent_buffer
end

function M.delete_current_buffer_keeping_window()
  local current_buffer = vim.api.nvim_get_current_buf()
  local replacement_buffer = M.find_most_recent_listed_buffer(
    function(buffer) return buffer == current_buffer end
  )
  if replacement_buffer then
    vim.api.nvim_set_current_buf(replacement_buffer)
  end
  vim.cmd('bdelete ' .. current_buffer)
end

---@param buf integer
---@return boolean
function M.is_database_buffer(buf)
  return vim.bo[buf].filetype == DatabaseFiletypeEnum.result
    or vim.b[buf].dbui_db_key_name ~= nil
end

return M
