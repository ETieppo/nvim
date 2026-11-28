local toast_config = require 'layout.toast.def'
local toast_enums = require 'layout.toast.enums'
local uv_handle = require 'utils.uv_handle'

---@class ToastRequestProps
---@field message string
---@field level ToastLevelEnum
---@field title string|nil
---@field id string|integer|nil
---@field timeout integer|nil

---@class ToastProps
---@field id string|integer|nil
---@field buffer integer
---@field window integer
---@field timer uv.uv_timer_t
---@field on_timeout? fun()
---@field height integer
---@field timeout integer|nil
---@field window_highlight string|nil

---@class ToastLevelPresentationProps
---@field title string
---@field title_width integer
---@field window_highlight string

---@class ToastContentProps
---@field lines string[]
---@field widths integer[]
---@field max_width integer

local M = {}

local BORDER_HEIGHT = toast_config.border == 'none' and 0 or 2
local HAS_BORDER = toast_config.border ~= 'none'
local TITLE_POSITION = 'left'
local PLAIN_ASCII_PATTERN = '[^\32-\126]'
local CONTROL_CHARACTER_PATTERN = '%c'
local UTF8_CHARACTER_PATTERN = '[%z\1-\127\194-\244][\128-\191]*'
local TAB_REPLACEMENT = '  '
local CONTENT_WIDTH = toast_config.max_width
  - toast_config.padding.left
  - toast_config.padding.right
local LEFT_PADDING = (' '):rep(toast_config.padding.left)
local DEFAULT_STYLE = toast_config.styles[toast_enums.ToastLevelEnum.info]
---@type table<ToastLevelEnum, ToastLevelPresentationProps>
local level_presentations = {}
---@type table<integer, string>
local spaces_by_width = {}
---@type ToastProps[]
local active_toasts = {}
---@type ToastRequestProps[]
local pending_requests = {}
---@type ToastProps[]
local pending_closures = {}
local is_flush_scheduled = false
local toast_group =
  vim.api.nvim_create_augroup('layout-toast', { clear = true })

local function is_cmdwin_active() return vim.fn.getcmdwintype() ~= '' end

---@param text string
---@return integer
local function get_display_width(text)
  if not text:find(PLAIN_ASCII_PATTERN) then return #text end
  if text:find(CONTROL_CHARACTER_PATTERN) then
    return vim.fn.strdisplaywidth(text)
  end
  return vim.api.nvim_strwidth(text)
end

---@param width integer
---@return string
local function get_spaces(width)
  local spaces = spaces_by_width[width]
  if spaces then return spaces end
  spaces = (' '):rep(width)
  spaces_by_width[width] = spaces
  return spaces
end

---@param level ToastLevelEnum
---@return ToastLevelPresentationProps
local function get_level_presentation(level)
  local presentation = level_presentations[level]
  if presentation then return presentation end

  local style = toast_config.styles[level] or DEFAULT_STYLE
  local title = ' '
    .. toast_config.kind_open_delimiter
    .. style.icon
    .. toast_config.kind_close_delimiter
    .. ' '
  presentation = {
    title = title,
    title_width = get_display_width(title),
    window_highlight = 'Normal:'
      .. style.body_highlight
      .. ',FloatBorder:'
      .. style.border_highlight
      .. ',FloatTitle:'
      .. style.title_highlight,
  }
  level_presentations[level] = presentation
  return presentation
end

---@param content ToastContentProps
---@param line string
---@param width integer
local function push_line(content, line, width)
  local index = #content.lines + 1
  content.lines[index] = line
  content.widths[index] = width
  if width > content.max_width then content.max_width = width end
end

---@param content ToastContentProps
---@param word string
---@return string current
---@return integer current_width
local function push_word_by_width(content, word)
  local current, current_width = '', 0
  for character in word:gmatch(UTF8_CHARACTER_PATTERN) do
    local character_width = get_display_width(character)
    if current ~= '' and current_width + character_width > CONTENT_WIDTH then
      push_line(content, current, current_width)
      current, current_width = character, character_width
    else
      current, current_width =
        current .. character, current_width + character_width
    end
  end
  return current, current_width
end

---@param content ToastContentProps
---@param line string
local function push_wrapped_line(content, line)
  local line_width = get_display_width(line)
  if line_width <= CONTENT_WIDTH then
    push_line(content, line, line_width)
    return
  end

  local current, current_width = '', 0
  local position = 1
  local line_length = #line
  while position <= line_length + 1 do
    local separator = line:find(' ', position, true) or line_length + 1
    local word = line:sub(position, separator - 1)
    local word_width = get_display_width(word)
    local candidate_width = current == '' and word_width
      or current_width + 1 + word_width

    if candidate_width <= CONTENT_WIDTH then
      current = current == '' and word or current .. ' ' .. word
      current_width = candidate_width
    else
      if current ~= '' then push_line(content, current, current_width) end
      current, current_width = push_word_by_width(content, word)
    end
    position = separator + 1
  end
  push_line(content, current, current_width)
end

---@param message string
---@return ToastContentProps
local function build_content(message)
  ---@type ToastContentProps
  local content = { lines = {}, widths = {}, max_width = 0 }
  local position = 1
  local message_length = #message
  while position <= message_length + 1 do
    local line_end = message:find('\n', position, true) or message_length + 1
    local line = message:sub(position, line_end - 1)
    if line:find('\t', 1, true) then line = line:gsub('\t', TAB_REPLACEMENT) end
    push_wrapped_line(content, line)
    position = line_end + 1
  end
  return content
end

---@param content ToastContentProps
---@return string[] lines
---@return integer width
local function apply_padding(content)
  local padding = toast_config.padding
  local padded_lines = {}
  for _ = 1, padding.top do
    padded_lines[#padded_lines + 1] = ''
  end
  for index, line in ipairs(content.lines) do
    local trailing_width = content.max_width - content.widths[index]
    padded_lines[#padded_lines + 1] = LEFT_PADDING
      .. line
      .. get_spaces(trailing_width + padding.right)
  end
  for _ = 1, padding.bottom do
    padded_lines[#padded_lines + 1] = ''
  end
  return padded_lines, content.max_width + padding.left + padding.right
end

---@return integer
local function get_bottom_row()
  local statusline_height = vim.o.laststatus > 0 and 1 or 0
  return vim.o.lines
    - vim.o.cmdheight
    - statusline_height
    - toast_config.margin.bottom
end

local function reposition()
  local row = get_bottom_row()
  local column = vim.o.columns - toast_config.margin.right
  for index = #active_toasts, 1, -1 do
    local toast = active_toasts[index]
    local outer_height = toast.height + BORDER_HEIGHT
    vim.api.nvim_win_set_config(toast.window, {
      relative = 'editor',
      anchor = 'SE',
      row = row,
      col = column,
      hide = row - outer_height < 0,
    })
    row = row - outer_height - toast_config.gap
  end
end

---@param toast ToastProps
local function destroy_toast(toast)
  uv_handle.close(toast.timer)
  if vim.api.nvim_win_is_valid(toast.window) then
    vim.api.nvim_win_close(toast.window, true)
  end
  if vim.api.nvim_buf_is_valid(toast.buffer) then
    vim.api.nvim_buf_delete(toast.buffer, { force = true })
  end
end

---@param toast ToastProps
local function dismiss_toast(toast)
  for index, active_toast in ipairs(active_toasts) do
    if active_toast == toast then
      table.remove(active_toasts, index)
      break
    end
  end

  if is_cmdwin_active() then
    vim.api.nvim_win_set_config(toast.window, { hide = true })
    pending_closures[#pending_closures + 1] = toast
  else
    destroy_toast(toast)
  end
  reposition()
end

---@param id string|integer|nil
---@return ToastProps|nil
local function find_toast(id)
  if id == nil then return nil end
  for _, toast in ipairs(active_toasts) do
    if toast.id == id then return toast end
  end
  return nil
end

---@param id string|integer|nil
---@return ToastProps
local function create_toast(id)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buffer })
  local window = vim.api.nvim_open_win(buffer, false, {
    relative = 'editor',
    anchor = 'SE',
    row = 1,
    col = 1,
    width = 1,
    height = 1,
    style = 'minimal',
    border = toast_config.border,
    focusable = false,
    zindex = toast_config.zindex,
    noautocmd = true,
  })
  vim.api.nvim_set_option_value(
    'winblend',
    toast_config.blend,
    { win = window }
  )
  vim.api.nvim_set_option_value('wrap', false, { win = window })

  local toast = {
    id = id,
    buffer = buffer,
    window = window,
    timer = assert(vim.uv.new_timer()),
    height = 1,
  }
  active_toasts[#active_toasts + 1] = toast
  return toast
end

---@param toast ToastProps
---@return fun()
local function get_timeout_handler(toast)
  if not toast.on_timeout then
    toast.on_timeout = vim.schedule_wrap(function() dismiss_toast(toast) end)
  end
  return toast.on_timeout
end

---@param toast ToastProps
local function restart_timer(toast)
  toast.timer:stop()
  toast.timer:start(
    toast.timeout or toast_config.timeout,
    0,
    get_timeout_handler(toast)
  )
end

---@param request ToastRequestProps
local function render(request)
  local presentation = get_level_presentation(request.level)
  local lines, width = apply_padding(build_content(request.message))
  local toast = find_toast(request.id) or create_toast(request.id)

  toast.timeout = request.timeout
  vim.api.nvim_buf_set_lines(toast.buffer, 0, -1, false, lines)
  toast.height = #lines

  vim.api.nvim_win_set_config(toast.window, {
    width = HAS_BORDER and math.max(width, presentation.title_width) or width,
    height = toast.height,
    title = HAS_BORDER and presentation.title or nil,
    title_pos = HAS_BORDER and TITLE_POSITION or nil,
  })
  if toast.window_highlight ~= presentation.window_highlight then
    vim.api.nvim_set_option_value(
      'winhighlight',
      presentation.window_highlight,
      { win = toast.window }
    )
    toast.window_highlight = presentation.window_highlight
  end

  restart_timer(toast)
end

local function flush_pending()
  is_flush_scheduled = false
  if is_cmdwin_active() then return end

  for _, toast in ipairs(pending_closures) do
    destroy_toast(toast)
  end
  pending_closures = {}

  local requests = pending_requests
  pending_requests = {}
  for _, request in ipairs(requests) do
    render(request)
  end
  reposition()
end

local function schedule_flush()
  if is_flush_scheduled then return end
  is_flush_scheduled = true
  vim.schedule(flush_pending)
end

---@param request ToastRequestProps
function M.show(request)
  request.message = vim.trim(request.message)
  if request.message == '' then return end
  pending_requests[#pending_requests + 1] = request
  schedule_flush()
end

vim.api.nvim_create_autocmd('CmdwinLeave', {
  desc = 'Render toasts queued while the command-line window was open',
  group = toast_group,
  callback = schedule_flush,
})

vim.api.nvim_create_autocmd('VimResized', {
  desc = 'Keep toasts anchored after a resize',
  group = toast_group,
  callback = reposition,
})

return M
