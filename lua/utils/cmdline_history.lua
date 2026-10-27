---@class CmdlineHistoryStateProps
---@field prefix string
---@field typed_text string
---@field recalled_text string
---@field history_index integer

---@class CmdlineHistoryKeymapProps
---@field modes string[]
---@field lhs string
---@field step integer
---@field desc string

local M = {}

---@type table<integer, CmdlineHistoryStateProps>
local states = {}

---@type CmdlineHistoryKeymapProps[]
local keymaps = {
  {
    modes = { 'i', 'n' },
    lhs = '<Up>',
    step = -1,
    desc = 'Previous history entry with the typed prefix',
  },
  {
    modes = { 'i', 'n' },
    lhs = '<Down>',
    step = 1,
    desc = 'Next history entry with the typed prefix',
  },
  {
    modes = { 'n' },
    lhs = 'k',
    step = -1,
    desc = 'Previous history entry with the typed prefix',
  },
  {
    modes = { 'n' },
    lhs = 'j',
    step = 1,
    desc = 'Next history entry with the typed prefix',
  },
}

---@param line string
---@param prefix string
---@return boolean
function M.matches_prefix(line, prefix)
  local ignore_case = vim.o.ignorecase
    and not (vim.o.smartcase and prefix:find '%u')
  if ignore_case then return vim.startswith(line:lower(), prefix:lower()) end
  return vim.startswith(line, prefix)
end

---@param lines string[]
---@param editing_row integer
---@param prefix string
---@param start_index integer
---@param step integer
---@return integer|nil
function M.find_match(lines, editing_row, prefix, start_index, step)
  local index = start_index + step
  while index >= 1 and index <= #lines do
    if index ~= editing_row and M.matches_prefix(lines[index], prefix) then
      return index
    end
    index = index + step
  end
  return nil
end

---@param buffer integer
---@param editing_row integer
---@param current_text string
---@return CmdlineHistoryStateProps
local function get_state(buffer, editing_row, current_text)
  local state = states[buffer]
  if state and state.recalled_text == current_text then return state end

  state = {
    prefix = current_text,
    typed_text = current_text,
    recalled_text = current_text,
    history_index = editing_row,
  }
  states[buffer] = state
  return state
end

---@param text string
local function replace_current_line(text)
  vim.api.nvim_set_current_line(text)
  vim.api.nvim_win_set_cursor(0, { vim.fn.line '.', #text })
end

---@param step integer
function M.navigate(step)
  local buffer = vim.api.nvim_get_current_buf()
  local editing_row = vim.fn.line '.'
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  local state = get_state(buffer, editing_row, vim.api.nvim_get_current_line())

  local match =
    M.find_match(lines, editing_row, state.prefix, state.history_index, step)

  if match then
    state.history_index = match
    state.recalled_text = lines[match]
  elseif step > 0 then
    state.history_index = editing_row
    state.recalled_text = state.typed_text
  else
    return
  end

  replace_current_line(state.recalled_text)
end

---@param step integer
local function navigate_with_count(step)
  for _ = 1, vim.v.count1 do
    M.navigate(step)
  end
end

---@param buffer integer
function M.attach(buffer)
  states[buffer] = nil
  for _, keymap in ipairs(keymaps) do
    vim.keymap.set(
      keymap.modes,
      keymap.lhs,
      function() navigate_with_count(keymap.step) end,
      { buffer = buffer, desc = keymap.desc }
    )
  end
end

return M
