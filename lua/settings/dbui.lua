local M = {}
local api = vim.api

---@param buf integer
---@return boolean
function M.is_db_buf(buf)
  return vim.bo[buf].filetype == 'dbout' or vim.b[buf].dbui_db_key_name ~= nil
end

---@return integer|nil
local function drawer_win()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if vim.bo[api.nvim_win_get_buf(win)].filetype == 'dbui' then return win end
  end
end

---@return integer
local function fallback_buf()
  local best, last = nil, -1
  for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
    if info.lastused > last and not M.is_db_buf(info.bufnr) then
      best, last = info.bufnr, info.lastused
    end
  end
  return best or api.nvim_create_buf(true, false)
end

local function close()
  local fallback
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and M.is_db_buf(buf) then
      local is_result = vim.bo[buf].filetype == 'dbout'

      if vim.bo[buf].modified then
        pcall(
          api.nvim_buf_call,
          buf,
          function() vim.cmd 'silent noautocmd write' end
        )
      end

      for _, win in ipairs(vim.fn.win_findbuf(buf)) do
        if not (is_result and pcall(api.nvim_win_close, win, false)) then
          fallback = fallback or fallback_buf()
          api.nvim_win_set_buf(win, fallback)
        end
      end

      if not pcall(api.nvim_buf_delete, buf, {}) then
        vim.notify(
          'Could not close ' .. api.nvim_buf_get_name(buf),
          vim.log.levels.WARN,
          { title = 'DBUI' }
        )
      end
    end
  end
  vim.cmd 'DBUIClose'
end

function M.toggle()
  if drawer_win() then return close() end
  vim.cmd 'DBUI'
end

return M
