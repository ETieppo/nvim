local storage = require 'useless.wpm.storage'

---@class BufferlineSectionProps
---@field text string
---@field link string

local M = {}
local CHARACTERS_PER_WORD = 5
local MILLISECONDS_PER_MINUTE = 60000
local MINIMUM_ACTIVE_MILLISECONDS = 60000
local BASELINE_DAYS = 7
local HIGHLIGHT_GROUP = 'BufferLineBackground'
local KEYBOARD_ICON = '󰌌'
local INCREASE_ICON = '▲'
local DECREASE_ICON = '▼'
---@type BufferlineSectionProps[]|nil
local sections = nil
local current_label = ''

---@param value number
---@return integer
local function round(value) return math.floor(value + 0.5) end

---@param record DailyTypingDto
---@return number
function M.calculate_wpm(record)
  if record.active_milliseconds <= 0 then return 0 end
  return (record.net_characters / CHARACTERS_PER_WORD)
    / (record.active_milliseconds / MILLISECONDS_PER_MINUTE)
end

---@param record DailyTypingDto
---@return integer|nil
local function calculate_reliable_wpm(record)
  if record.active_milliseconds < MINIMUM_ACTIVE_MILLISECONDS then
    return nil
  end
  return round(M.calculate_wpm(record))
end

---@param difference integer
---@return string
local function format_trend(difference)
  if difference > 0 then return ' ' .. INCREASE_ICON .. difference end
  if difference < 0 then return ' ' .. DECREASE_ICON .. -difference end
  return ''
end

---@return string
local function build_label()
  local today_wpm = calculate_reliable_wpm(storage.sum_days(0, 0))
  local baseline_wpm =
    calculate_reliable_wpm(storage.sum_days(1, BASELINE_DAYS))

  if today_wpm and baseline_wpm then
    return string.format(
      ' %s %d wpm%s ',
      KEYBOARD_ICON,
      today_wpm,
      format_trend(today_wpm - baseline_wpm)
    )
  end
  if today_wpm then
    return string.format(' %s %d wpm ', KEYBOARD_ICON, today_wpm)
  end
  if baseline_wpm then
    return string.format(
      ' %s %dd %d wpm ',
      KEYBOARD_ICON,
      BASELINE_DAYS,
      baseline_wpm
    )
  end
  return ''
end

---@return boolean
local function update_sections()
  local label = build_label()
  local has_changed = sections == nil or label ~= current_label

  current_label = label
  sections = label == '' and {} or { { text = label, link = HIGHLIGHT_GROUP } }
  return has_changed
end

function M.refresh()
  if update_sections() then vim.cmd.redrawtabline() end
end

---@return BufferlineSectionProps[]
function M.get_bufferline_sections()
  if not sections then update_sections() end
  ---@cast sections BufferlineSectionProps[]
  return sections
end

return M
