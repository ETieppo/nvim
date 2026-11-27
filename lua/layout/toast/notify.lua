local toast_enums = require 'layout.toast.enums'

---@class ToastNotifyOptsProps
---@field title string|nil
---@field id string|integer|nil
---@field timeout integer|nil

---@alias ToastLevelNotifierProps fun(message: any, opts: ToastNotifyOptsProps|nil)

---@class ToastNotifierProps
---@overload fun(message: any, level: integer|nil, opts: ToastNotifyOptsProps|nil)
---@field error ToastLevelNotifierProps
---@field warn ToastLevelNotifierProps
---@field info ToastLevelNotifierProps
---@field debug ToastLevelNotifierProps
---@field success ToastLevelNotifierProps
---@field trace ToastLevelNotifierProps

local ToastLevelEnum = toast_enums.ToastLevelEnum
---@type table<integer, ToastLevelEnum>
local TOAST_LEVEL_BY_LOG_LEVEL = {
  [vim.log.levels.TRACE] = ToastLevelEnum.trace,
  [vim.log.levels.DEBUG] = ToastLevelEnum.debug,
  [vim.log.levels.INFO] = ToastLevelEnum.info,
  [vim.log.levels.WARN] = ToastLevelEnum.warn,
  [vim.log.levels.ERROR] = ToastLevelEnum.error,
}

---@param message any
---@param toast_level ToastLevelEnum
---@param opts ToastNotifyOptsProps|nil
local function show_notification(message, toast_level, opts)
  opts = opts or {}
  require('layout.toast.renderer').show {
    message = tostring(message),
    level = toast_level,
    title = opts.title,
    id = opts.id,
    timeout = opts.timeout,
  }
end

---@param toast_level ToastLevelEnum
---@return ToastLevelNotifierProps
local function create_level_notifier(toast_level)
  return function(message, opts) show_notification(message, toast_level, opts) end
end

---@param _ ToastNotifierProps
---@param message any
---@param log_level integer|nil
---@param opts ToastNotifyOptsProps|nil
local function call_notifier(_, message, log_level, opts)
  if log_level == vim.log.levels.OFF then return end
  show_notification(
    message,
    TOAST_LEVEL_BY_LOG_LEVEL[log_level] or ToastLevelEnum.trace,
    opts
  )
end

---@type ToastNotifierProps
local M = {
  error = create_level_notifier(ToastLevelEnum.error),
  warn = create_level_notifier(ToastLevelEnum.warn),
  info = create_level_notifier(ToastLevelEnum.info),
  debug = create_level_notifier(ToastLevelEnum.debug),
  success = create_level_notifier(ToastLevelEnum.success),
  trace = create_level_notifier(ToastLevelEnum.trace),
}

setmetatable(M, { __call = call_notifier })

rawset(vim, 'notify', M)

return M
