local buffer_mod = require 'buffer.buffer'
local IMAGE_FILETYPE = 'image'
local AUTOSAVE_EVENTS = {
  'InsertLeave',
  'TextChanged',
  'FocusLost',
  'BufLeave',
}

---@param buffer integer
---@return boolean
local function should_autosave(buffer)
  return vim.bo[buffer].modified
    and vim.bo[buffer].buftype == ''
    and not buffer_mod.is_database_buffer(buffer)
    and vim.api.nvim_buf_get_name(buffer) ~= ''
end

---@param buffer integer
---@return boolean
local function is_unused_empty_buffer(buffer)
  return vim.api.nvim_buf_is_valid(buffer)
    and vim.api.nvim_buf_get_name(buffer) == ''
    and vim.bo[buffer].buflisted
    and vim.bo[buffer].buftype == ''
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
  callback = function()
    -- TODO:
    -- HACK: remove when 0.13 get stable
    if vim.version().minor < 13 then
      vim.hl.on_yank { timeout = 300 }
    else
      vim.hl.hl_op { timeout = 300 }
    end
  end,
})
