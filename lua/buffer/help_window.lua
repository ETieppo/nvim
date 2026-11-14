---@class HelpWindowCandidateProps
---@field help_window integer
---@field source_window integer

local HELP_BUFTYPE = 'help'
local REPLACEABLE_BUFTYPES = { [''] = true, [HELP_BUFTYPE] = true }
---@type HelpWindowCandidateProps|nil
local pending_candidate = nil
local help_window_group =
  vim.api.nvim_create_augroup('help-current-window', { clear = true })

---@param window integer
---@return boolean
local function is_replaceable_window(window)
  if window == 0 or not vim.api.nvim_win_is_valid(window) then return false end
  if vim.api.nvim_win_get_config(window).relative ~= '' then return false end
  local buffer = vim.api.nvim_win_get_buf(window)
  return REPLACEABLE_BUFTYPES[vim.bo[buffer].buftype] == true
end

---@param candidate HelpWindowCandidateProps
local function move_help_to_source_window(candidate)
  local help_window = candidate.help_window
  local source_window = candidate.source_window
  if
    not vim.api.nvim_win_is_valid(help_window)
    or not is_replaceable_window(source_window)
  then
    return
  end

  local help_buffer = vim.api.nvim_win_get_buf(help_window)
  if vim.bo[help_buffer].buftype ~= HELP_BUFTYPE then return end

  local view = vim.api.nvim_win_call(help_window, vim.fn.winsaveview)
  vim.api.nvim_win_set_buf(source_window, help_buffer)
  vim.api.nvim_win_call(source_window, function() vim.fn.winrestview(view) end)
  vim.api.nvim_set_current_win(source_window)
  vim.api.nvim_win_close(help_window, false)
end

vim.api.nvim_create_autocmd('WinNew', {
  desc = 'Remember the window a new split came from',
  group = help_window_group,
  callback = function()
    pending_candidate = {
      help_window = vim.api.nvim_get_current_win(),
      source_window = vim.fn.win_getid(vim.fn.winnr '#'),
    }
  end,
})

vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Open help as a listed buffer in the current window',
  group = help_window_group,
  callback = function(event)
    local candidate = pending_candidate
    pending_candidate = nil
    if vim.bo[event.buf].buftype ~= HELP_BUFTYPE then return end

    vim.bo[event.buf].buflisted = true
    if
      candidate == nil
      or candidate.help_window ~= vim.api.nvim_get_current_win()
    then
      return
    end
    vim.schedule(function() move_help_to_source_window(candidate) end)
  end,
})
