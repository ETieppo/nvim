local dtos = require 'useless.wpm.dtos'

local M = {}
local HISTORY_DIRECTORY = vim.fs.joinpath(vim.fn.stdpath 'state', 'useless')
local HISTORY_FILE = vim.fs.joinpath(HISTORY_DIRECTORY, 'wpm.json')
local TEMPORARY_HISTORY_FILE = HISTORY_FILE .. '.tmp'
local CORRUPTED_HISTORY_FILE = HISTORY_FILE .. '.corrupted'
local FLUSH_DELAY_MILLISECONDS = 60000
local DAY_KEY_FORMAT = '%Y-%m-%d'
local DAY_KEY_HOUR = 12
---@type TypingHistoryDto|nil
local history = nil
---@type table<string, DailyTypingDto>
local pending_days = {}
local is_flush_scheduled = false

---@param target DailyTypingDto
---@param source DailyTypingDto
local function accumulate(target, source)
  target.net_characters = target.net_characters + (source.net_characters or 0)
  target.raw_characters = target.raw_characters + (source.raw_characters or 0)
  target.active_milliseconds = target.active_milliseconds
    + (source.active_milliseconds or 0)
end

---@param offset_days integer
---@return string
local function get_day_key(offset_days)
  local today = os.date '*t'
  ---@cast today osdate
  return tostring(os.date(
    DAY_KEY_FORMAT,
    os.time {
      year = today.year,
      month = today.month,
      day = today.day - offset_days,
      hour = DAY_KEY_HOUR,
    }
  ))
end

---@return TypingHistoryDto
local function read_history_file()
  local file = io.open(HISTORY_FILE, 'r')
  if not file then return dtos.TypingHistoryDto.new() end

  local content = file:read '*a'
  file:close()

  local is_decoded, decoded = pcall(vim.json.decode, content)
  if
    is_decoded
    and type(decoded) == 'table'
    and type(decoded.days) == 'table'
  then
    return decoded
  end

  os.rename(HISTORY_FILE, CORRUPTED_HISTORY_FILE)
  return dtos.TypingHistoryDto.new()
end

---@param content TypingHistoryDto
---@return boolean
local function write_history_file(content)
  vim.fn.mkdir(HISTORY_DIRECTORY, 'p')

  local file = io.open(TEMPORARY_HISTORY_FILE, 'w')
  if not file then return false end

  file:write(vim.json.encode(content))
  file:close()
  return os.rename(TEMPORARY_HISTORY_FILE, HISTORY_FILE) == true
end

---@return TypingHistoryDto
local function get_history()
  if not history then history = read_history_file() end
  return history
end

function M.flush()
  is_flush_scheduled = false
  if next(pending_days) == nil then return end

  local merged_history = read_history_file()
  for day, record in pairs(pending_days) do
    merged_history.days[day] = merged_history.days[day]
      or dtos.DailyTypingDto.new()
    accumulate(merged_history.days[day], record)
  end

  if not write_history_file(merged_history) then return end
  history = merged_history
  pending_days = {}
end

local function schedule_flush()
  if is_flush_scheduled then return end
  is_flush_scheduled = true
  vim.defer_fn(M.flush, FLUSH_DELAY_MILLISECONDS)
end

---@param record DailyTypingDto
function M.add_to_today(record)
  local today = get_day_key(0)
  pending_days[today] = pending_days[today] or dtos.DailyTypingDto.new()
  accumulate(pending_days[today], record)
  schedule_flush()
end

---@param first_offset_days integer
---@param last_offset_days integer
---@return DailyTypingDto
function M.sum_days(first_offset_days, last_offset_days)
  local stored_days = get_history().days
  local total = dtos.DailyTypingDto.new()

  for offset_days = first_offset_days, last_offset_days do
    local day = get_day_key(offset_days)
    if stored_days[day] then accumulate(total, stored_days[day]) end
    if pending_days[day] then accumulate(total, pending_days[day]) end
  end
  return total
end

return M
