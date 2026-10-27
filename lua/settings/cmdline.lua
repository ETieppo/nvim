local cmdline_preview = require 'utils.cmdline_preview'
local cmdline_history = require 'utils.cmdline_history'
local FLOATING_CMDLINE_WIDTH = 60
local FLOATING_CMDLINE_ROW = 2
local FLOATING_CMDLINE_TITLES = {
  [':'] = ' Cmdline ',
  ['/'] = ' Search forward ',
  ['?'] = ' Search backward ',
}
local pending_initial_text = nil
local native_win_gettype = vim.fn.win_gettype
local floating_cmdline_group =
  vim.api.nvim_create_augroup('floating-cmdline', { clear = true })

local function is_current_window(window)
  return window == nil
    or window == 0
    or window == vim.api.nvim_get_current_win()
    or window == vim.fn.winnr()
end

rawset(vim.fn, 'win_gettype', function(window)
  if vim.fn.getcmdwintype() ~= '' and is_current_window(window) then
    return 'command'
  end
  return native_win_gettype(window)
end)

local function is_visual_mode() return vim.fn.mode():match '[vV\22]' ~= nil end
local function is_macro_active()
  return vim.fn.reg_recording() ~= '' or vim.fn.reg_executing() ~= ''
end

local function resolve_range()
  if is_visual_mode() then return "'<,'>" end
  if vim.v.count > 0 then return '.,.+' .. (vim.v.count - 1) end
  return ''
end

local function open_floating_cmdline(cmdline_type)
  return function()
    if is_macro_active() then return cmdline_type end
    if cmdline_type ~= ':' and vim.v.count > 0 then return cmdline_type end
    pending_initial_text = cmdline_type == ':' and resolve_range() or ''
    return '<Esc>q' .. cmdline_type
  end
end

local function float_cmdwin(window)
  local width = math.min(FLOATING_CMDLINE_WIDTH, vim.o.columns - 4)
  vim.api.nvim_win_set_config(window, {
    relative = 'editor',
    row = FLOATING_CMDLINE_ROW,
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = 1,
    border = 'rounded',
    title = FLOATING_CMDLINE_TITLES[vim.fn.getcmdwintype()],
    title_pos = 'center',
    zindex = 200,
  })
  vim.wo[window].number = false
  vim.wo[window].relativenumber = false
  vim.wo[window].signcolumn = 'no'
  vim.wo[window].statuscolumn = '%#NonText#' .. vim.fn.getcmdwintype()
  vim.wo[window].winhighlight =
    'NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle'
end

vim.keymap.set(
  { 'n', 'x' },
  ':',
  open_floating_cmdline ':',
  { expr = true, desc = 'Open floating command line' }
)

vim.keymap.set(
  'n',
  '/',
  open_floating_cmdline '/',
  { expr = true, desc = 'Open floating forward search' }
)

vim.keymap.set(
  'n',
  '?',
  open_floating_cmdline '?',
  { expr = true, desc = 'Open floating backward search' }
)

vim.api.nvim_create_autocmd('CmdwinLeave', {
  desc = 'Remove the command-line previews',
  group = floating_cmdline_group,
  callback = cmdline_preview.detach,
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
  desc = 'Turn the command-line window into a floating prompt',
  group = floating_cmdline_group,
  callback = function(event)
    local source_window = vim.fn.win_getid(vim.fn.winnr '#')
    float_cmdwin(vim.api.nvim_get_current_win())
    vim.keymap.set('n', '<Esc>', '<cmd>quit<CR>', { buffer = event.buf })
    cmdline_history.attach(event.buf)

    if source_window ~= 0 then
      cmdline_preview.attach(event.buf, source_window, vim.fn.getcmdwintype())
    end
    if pending_initial_text == nil then return end

    vim.api.nvim_set_current_line(pending_initial_text)
    pending_initial_text = nil
    vim.cmd 'startinsert!'
  end,
})
