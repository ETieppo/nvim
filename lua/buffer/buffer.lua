local helpers = require 'utils.helpers'
local DATABASE_OUTPUT_FILETYPE = 'dbout'
local IMAGE_FILETYPE = 'image'
local AUTOSAVE_EVENTS = {
  'InsertLeave',
  'TextChanged',
  'FocusLost',
  'BufLeave',
}

local M = {}

---@param buffer integer
---@return boolean
function M.is_database_buffer(buffer)
  return vim.bo[buffer].filetype == DATABASE_OUTPUT_FILETYPE
    or vim.b[buffer].dbui_db_key_name ~= nil
end

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

---@param buffer integer
---@return boolean
local function should_autosave(buffer)
  return vim.bo[buffer].modified
    and vim.bo[buffer].buftype == ''
    and not M.is_database_buffer(buffer)
    and vim.api.nvim_buf_get_name(buffer) ~= ''
end

---@param buffer integer
---@return boolean
local function is_unused_empty_buffer(buffer)
  return vim.api.nvim_buf_is_valid(buffer)
    and vim.bo[buffer].buflisted
    and vim.bo[buffer].buftype == ''
    and vim.api.nvim_buf_get_name(buffer) == ''
    and not vim.bo[buffer].modified
    and #vim.fn.win_findbuf(buffer) == 0
end

local function delete_unused_empty_buffers()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if is_unused_empty_buffer(buffer) then
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
  end
end

vim.keymap.set(
  'n',
  '<leader>bd',
  M.delete_current_buffer_keeping_window,
  { desc = '[B]uffer [D]elete' }
)

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Wipe image buffers when hidden',
  pattern = IMAGE_FILETYPE,
  callback = function(event) vim.bo[event.buf].bufhidden = 'wipe' end,
})

vim.api.nvim_create_autocmd(AUTOSAVE_EVENTS, {
  desc = 'Autosave',
  nested = true,
  callback = function(event)
    if should_autosave(event.buf) then
      vim.api.nvim_buf_call(event.buf, function() vim.cmd 'silent! write' end)
    end
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Delete unused empty buffers after opening a named one',
  callback = function()
    if vim.api.nvim_buf_get_name(0) == '' then return end
    vim.schedule(delete_unused_empty_buffers)
  end,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup(
    'highlight-yanked-text',
    { clear = true }
  ),
  callback = function() vim.hl.hl_op { timeout = 300 } end,
})

return M
