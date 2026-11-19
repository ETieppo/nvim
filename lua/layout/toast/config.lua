local toast_enums = require 'layout.toast.enums'
local ToastLevelEnum = toast_enums.ToastLevelEnum

---@class ToastLevelStyleProps
---@field icon string
---@field body_highlight string
---@field border_highlight string
---@field title_highlight string

---@class ToastMarginProps
---@field right integer
---@field bottom integer

---@class ToastPaddingProps
---@field top integer
---@field right integer
---@field bottom integer
---@field left integer

---@class ToastConfigProps
---@field max_width integer
---@field timeout integer
---@field gap integer
---@field zindex integer
---@field blend integer
---@field border string|string[]
---@field margin ToastMarginProps
---@field padding ToastPaddingProps
---@field styles table<ToastLevelEnum, ToastLevelStyleProps>
---@field kind_open_delimiter string
---@field kind_close_delimiter string

---@type ToastConfigProps
return {
  max_width = 60,
  timeout = 4000,
  gap = 1,
  zindex = 250,
  blend = 0,
  border = 'rounded',
  margin = { right = 2, bottom = 1 },
  padding = { top = 1, right = 2, bottom = 1, left = 2 },
  kind_open_delimiter = '🭼 ',
  kind_close_delimiter = ' 🭾',
  styles = {
    [ToastLevelEnum.error] = {
      icon = 'ERR',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastErrorBorder',
      title_highlight = 'ToastErrorTitle',
    },
    [ToastLevelEnum.warn] = {
      icon = 'WARN',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastWarnBorder',
      title_highlight = 'ToastWarnTitle',
    },
    [ToastLevelEnum.info] = {
      icon = 'INFO',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastInfoBorder',
      title_highlight = 'ToastInfoTitle',
    },
    [ToastLevelEnum.debug] = {
      icon = 'DEBUG',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastDebugBorder',
      title_highlight = 'ToastDebugTitle',
    },
    [ToastLevelEnum.success] = {
      icon = 'SUCCESS',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastSuccessBorder',
      title_highlight = 'ToastSuccessTitle',
    },
    [ToastLevelEnum.trace] = {
      icon = 'TRACE',
      body_highlight = 'ToastBody',
      border_highlight = 'ToastTraceBorder',
      title_highlight = 'ToastTraceTitle',
    },
  },
}
