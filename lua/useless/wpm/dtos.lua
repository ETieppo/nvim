---@class DailyTypingDto
---@field net_characters number
---@field raw_characters number
---@field active_milliseconds number

---@class TypingHistoryDto
---@field version integer
---@field days table<string, DailyTypingDto>

local M = {}
local TYPING_HISTORY_VERSION = 1

M.DailyTypingDto = {}
M.TypingHistoryDto = {}

---@param net_characters? number
---@param raw_characters? number
---@param active_milliseconds? number
---@return DailyTypingDto
function M.DailyTypingDto.new(
  net_characters,
  raw_characters,
  active_milliseconds
)
  return {
    net_characters = net_characters or 0,
    raw_characters = raw_characters or 0,
    active_milliseconds = active_milliseconds or 0,
  }
end

---@return TypingHistoryDto
function M.TypingHistoryDto.new()
  return { version = TYPING_HISTORY_VERSION, days = vim.empty_dict() }
end

return M
