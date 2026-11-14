local dtos = require 'useless.wpm.dtos'
local enums = require 'useless.wpm.enums'
local keystroke = require 'useless.wpm.keystroke'
local metric = require 'useless.wpm.metric'
local storage = require 'useless.wpm.storage'

---@class TypingSessionProps
---@field typed_characters integer
---@field net_characters integer
---@field raw_characters integer
---@field active_nanoseconds number
---@field last_keystroke_at number|nil

local M = {}
local KeystrokeKindEnum = enums.KeystrokeKindEnum
local NANOSECONDS_PER_MILLISECOND = 1e6
local IDLE_GAP_NANOSECONDS = 1500 * NANOSECONDS_PER_MILLISECOND
local MAXIMUM_PLAUSIBLE_WPM = 300
local SESSION_AUGROUP_NAME = 'useless-wpm-session'
local TYPING_MODE_LEAVE_PATTERN = '[iR]*:[^iR]*'
local namespace = vim.api.nvim_create_namespace 'useless-wpm-collector'
local session_augroup =
  vim.api.nvim_create_augroup(SESSION_AUGROUP_NAME, { clear = true })
---@type TypingSessionProps|nil
local session = nil

---@param current_session TypingSessionProps
---@param kind KeystrokeKindEnum
---@param is_measured boolean
local function register_deletion(current_session, kind, is_measured)
  local deleted_characters = math.min(
    keystroke.count_deleted_characters(kind),
    current_session.typed_characters
  )
  current_session.typed_characters = current_session.typed_characters
    - deleted_characters
  if is_measured then
    current_session.net_characters = current_session.net_characters
      - deleted_characters
  end
end

---@param _ string
---@param typed string
local function handle_key(_, typed)
  local current_session = session
  if typed == '' or not current_session then return end

  local kind = keystroke.classify(typed)
  if kind == KeystrokeKindEnum.ignored then
    current_session.last_keystroke_at = nil
    return
  end

  local now = vim.uv.hrtime()
  local previous_keystroke_at = current_session.last_keystroke_at
  local is_measured = previous_keystroke_at ~= nil
    and now - previous_keystroke_at <= IDLE_GAP_NANOSECONDS
  current_session.last_keystroke_at = now

  if is_measured then
    current_session.active_nanoseconds = current_session.active_nanoseconds
      + now
      - previous_keystroke_at
  end

  if kind ~= KeystrokeKindEnum.character then
    register_deletion(current_session, kind, is_measured)
    return
  end

  current_session.typed_characters = current_session.typed_characters + 1
  if is_measured then
    current_session.net_characters = current_session.net_characters + 1
    current_session.raw_characters = current_session.raw_characters + 1
  end
end

---@param finished_session TypingSessionProps
---@return DailyTypingDto|nil
local function build_daily_record(finished_session)
  if finished_session.active_nanoseconds <= 0 then return nil end

  local record = dtos.DailyTypingDto.new(
    math.max(0, finished_session.net_characters),
    finished_session.raw_characters,
    finished_session.active_nanoseconds / NANOSECONDS_PER_MILLISECOND
  )
  if metric.calculate_wpm(record) > MAXIMUM_PLAUSIBLE_WPM then return nil end
  return record
end

function M.start()
  if session then return end
  if vim.bo.buftype ~= '' then return end

  session = {
    typed_characters = 0,
    net_characters = 0,
    raw_characters = 0,
    active_nanoseconds = 0,
    last_keystroke_at = nil,
  }
  vim.on_key(handle_key, namespace)
end

function M.stop()
  local finished_session = session
  if not finished_session then return end

  vim.on_key(nil, namespace)
  session = nil

  local record = build_daily_record(finished_session)
  if not record then return end

  storage.add_to_today(record)
  metric.refresh()
end

vim.api.nvim_create_autocmd('ModeChanged', {
  desc = 'Stop collecting the typing speed',
  group = session_augroup,
  pattern = TYPING_MODE_LEAVE_PATTERN,
  callback = M.stop,
})

vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Persist the collected typing speed',
  group = session_augroup,
  callback = function()
    M.stop()
    storage.flush()
  end,
})

return M
