local cmdline_history = require 'components.cmdline.history'
local cmdline_preview = require 'components.cmdline.preview'
local prompt_bar = require 'components.cmdline.prompt_bar'

---@class FloatingCmdlineKeymapProps
---@field modes string[]
---@field cmdline_type string
---@field desc string

---@type FloatingCmdlineKeymapProps[]
local FLOATING_CMDLINE_KEYMAPS = {
  {
    modes = { 'n', 'x' },
    cmdline_type = ':',
    desc = 'Open floating command line',
  },
  {
    modes = { 'n' },
    cmdline_type = '/',
    desc = 'Open floating forward search',
  },
  {
    modes = { 'n' },
    cmdline_type = '?',
    desc = 'Open floating backward search',
  },
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

local function get_range_for_current_mode()
  if is_visual_mode() then return "'<,'>" end
  if vim.v.count > 0 then return '.,.+' .. (vim.v.count - 1) end
  return ''
end

local function build_floating_cmdline_opener(cmdline_type)
  return function()
    if is_macro_active() then return cmdline_type end
    if cmdline_type ~= ':' and vim.v.count > 0 then return cmdline_type end
    pending_initial_text = cmdline_type == ':' and get_range_for_current_mode()
      or ''
    return '<Esc>q' .. cmdline_type
  end
end

local function turn_cmdwin_into_prompt_bar(window)
  vim.api.nvim_win_set_config(
    window,
    vim.tbl_extend('force', prompt_bar.window_config, { width = vim.o.columns })
  )
  vim.wo[window].number = false
  vim.wo[window].relativenumber = false
  vim.wo[window].signcolumn = 'no'
  vim.wo[window].cursorline = false
  vim.wo[window].colorcolumn = ''
  vim.wo[window].statuscolumn = '%#NonText#' .. vim.fn.getcmdwintype()
  vim.wo[window].winhighlight = prompt_bar.window_highlight
end

for _, keymap in ipairs(FLOATING_CMDLINE_KEYMAPS) do
  vim.keymap.set(
    keymap.modes,
    keymap.cmdline_type,
    build_floating_cmdline_opener(keymap.cmdline_type),
    { expr = true, desc = keymap.desc }
  )
end

vim.api.nvim_create_autocmd('CmdwinLeave', {
  desc = 'Remove the command-line previews',
  group = floating_cmdline_group,
  callback = cmdline_preview.detach,
})

vim.api.nvim_create_autocmd('CmdwinEnter', {
  desc = 'Turn the command-line window into a prompt bar',
  group = floating_cmdline_group,
  callback = function(event)
    local source_window = vim.fn.win_getid(vim.fn.winnr '#')
    turn_cmdwin_into_prompt_bar(vim.api.nvim_get_current_win())
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
