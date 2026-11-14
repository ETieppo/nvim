local toast_enums = require 'layout.toast.enums'
local toast_renderer = require 'layout.toast.renderer'
local ui2 = require 'vim._core.ui2'
local ui2_messages = require 'vim._core.ui2.messages'

local ToastLevelEnum = toast_enums.ToastLevelEnum
local native_msg_show = ui2_messages.msg_show
local UNDO_MESSAGE_KIND = 'undo'
local UNDO_LIMIT_PATTERN = '^Already at'
---@type table<string, ToastLevelEnum>
local TOAST_LEVEL_BY_MESSAGE_KIND = {
  [''] = ToastLevelEnum.info,
  bufwrite = ToastLevelEnum.info,
  echo = ToastLevelEnum.info,
  echomsg = ToastLevelEnum.info,
  lua_print = ToastLevelEnum.info,
  quickfix = ToastLevelEnum.info,
  undo = ToastLevelEnum.info,
  wmsg = ToastLevelEnum.warn,
  emsg = ToastLevelEnum.error,
  echoerr = ToastLevelEnum.error,
  lua_error = ToastLevelEnum.error,
  rpc_error = ToastLevelEnum.error,
}

---@param content [integer, string, integer?][]
---@return string
local function content_to_text(content)
  if #content == 1 then return content[1][2] end
  local chunks = {}
  for index, chunk in ipairs(content) do
    chunks[index] = chunk[2]
  end
  return table.concat(chunks)
end

ui2.enable {
  msg = {
    targets = {
      default = 'msg',
      list_cmd = 'pager',
      shell_out = 'pager',
    },
  },
}
vim.opt.messagesopt:append 'timeout:4000'

ui2_messages.msg_show = function(
  kind,
  content,
  replace_last,
  history,
  append,
  id,
  trigger
)
  local level = TOAST_LEVEL_BY_MESSAGE_KIND[kind]
  if level == nil then
    return native_msg_show(
      kind,
      content,
      replace_last,
      history,
      append,
      id,
      trigger
    )
  end

  local text = content_to_text(content)
  if kind == UNDO_MESSAGE_KIND and not text:find(UNDO_LIMIT_PATTERN) then
    return
  end
  if vim.fn.getcmdtype() ~= '' then
    return native_msg_show(
      kind,
      content,
      replace_last,
      history,
      append,
      id,
      trigger
    )
  end

  toast_renderer.show {
    message = text,
    level = level,
    id = id,
  }
end
