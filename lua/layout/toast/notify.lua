local toast_enums = require 'layout.toast.enums'
local toast_renderer = require 'layout.toast.renderer'

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

local ToastLevelEnum = toast_enums.ToastLevelEnum
---@type table<integer, ToastLevelEnum>
local TOAST_LEVEL_BY_LOG_LEVEL = {
  [vim.log.levels.TRACE] = ToastLevelEnum.debug,
  [vim.log.levels.DEBUG] = ToastLevelEnum.debug,
  [vim.log.levels.INFO] = ToastLevelEnum.info,
  [vim.log.levels.WARN] = ToastLevelEnum.warn,
  [vim.log.levels.ERROR] = ToastLevelEnum.error,
}

---@param message any
---@param level integer|nil
---@param opts ToastNotifyOptsProps|nil
local function show_notification(message, level, opts)
  if level == vim.log.levels.OFF then return end
  opts = opts or {}
  toast_renderer.show {
    message = tostring(message),
    level = TOAST_LEVEL_BY_LOG_LEVEL[level] or ToastLevelEnum.info,
    title = opts.title,
    id = opts.id,
    timeout = opts.timeout,
  }
end

---@param level integer
---@return ToastLevelNotifierProps
local function create_level_notifier(level)
  return function(message, opts) show_notification(message, level, opts) end
end

---@param _ ToastNotifierProps
---@param message any
---@param level integer|nil
---@param opts ToastNotifyOptsProps|nil
local function call_notifier(_, message, level, opts)
  show_notification(message, level, opts)
end

---@type ToastNotifierProps
local M = {
  error = create_level_notifier(vim.log.levels.ERROR),
  warn = create_level_notifier(vim.log.levels.WARN),
  info = create_level_notifier(vim.log.levels.INFO),
  debug = create_level_notifier(vim.log.levels.DEBUG),
}

setmetatable(M, { __call = call_notifier })

rawset(vim, 'notify', M)

return M
