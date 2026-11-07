local os_mod = require 'deps.sys'
local PROMPT_FILETYPE = 'snacks_input'

local M = {}

---@param cursor_column integer
local function place_prompt_cursor(cursor_column)
  local prompt_buffer = vim.api.nvim_get_current_buf()
  if vim.bo[prompt_buffer].filetype ~= PROMPT_FILETYPE then return end
  vim.api.nvim_create_autocmd('InsertEnter', {
    buffer = prompt_buffer,
    once = true,
    callback = function()
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() ~= prompt_buffer then return end
        vim.api.nvim_win_set_cursor(0, { 1, cursor_column })
      end)
    end,
  })
end

---@param prompt string
---@param default string
---@param cursor_column integer|nil
---@param on_confirm fun(path: string)
function M.prompt_path(prompt, default, cursor_column, on_confirm)
  vim.ui.input(
    { prompt = prompt, default = default, completion = 'file' },
    function(value)
      if value then on_confirm(value) end
    end
  )
  if cursor_column then place_prompt_cursor(cursor_column) end
end

---@param path string
---@param source_path? string
---@return string|nil
local function prepare_destination(path, source_path)
  local destination = os_mod.rewrite_to_os_path(path)
  if destination == '' or destination == source_path then return nil end
  vim.fn.mkdir(vim.fn.fnamemodify(destination, ':h'), 'p')
  return destination
end

---@param path string
local function open_file(path) vim.cmd('edit ' .. vim.fn.fnameescape(path)) end

---@param path string
function M.create_file(path)
  local destination = prepare_destination(path)
  if destination then open_file(destination) end
end

---@param source_path string
---@param path string
local function move_file(source_path, path)
  local destination = prepare_destination(path, source_path)
  if not destination then return end
  vim.fn.rename(source_path, destination)
  open_file(destination)
  vim.cmd 'bdelete! #'
end

---@param source_path string
---@param path string
local function copy_file(source_path, path)
  local destination = prepare_destination(path, source_path)
  if not destination then return end
  if vim.uv.fs_copyfile(source_path, destination) then
    open_file(destination)
  else
    vim.notify('Error at file clone.', vim.log.levels.ERROR)
  end
end

---@param prompt string
---@param on_confirm fun(source_path: string, path: string)
local function prompt_destination_for_current_file(prompt, on_confirm)
  local source_path = vim.fn.expand '%:p'
  local default = os_mod.normalize_os_path(source_path)
  local cursor_column = #default - #vim.fn.expand '%:t'
  M.prompt_path(
    prompt,
    default,
    cursor_column,
    function(path) on_confirm(source_path, path) end
  )
end

---@param file string
---@return string[]
local function build_trash_command(file)
  if os_mod.is_macos() then
    return {
      'osascript',
      '-e',
      string.format('tell application "Finder" to delete POSIX file %q', file),
    }
  end
  if os_mod.is_windows() then
    return {
      'powershell',
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      'Add-Type -AssemblyName Microsoft.VisualBasic; '
        .. "[Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile('"
        .. file:gsub("'", "''")
        .. "', 'OnlyErrorDialogs', 'SendToRecycleBin')",
    }
  end
  return { 'gio', 'trash', '--', file }
end

local function trash_current_file()
  local file = vim.fn.expand '%:p'
  if file == '' then
    vim.notify('No file to trash', vim.log.levels.WARN)
    return
  end
  if vim.fn.confirm('Trash file?\n' .. file, '&Yes\n&No', 2) ~= 1 then
    return
  end

  local result = vim.system(build_trash_command(file), { text = true }):wait()
  if result.code ~= 0 then
    vim.notify(
      'Trash failed: ' .. (result.stderr or 'unknown error'),
      vim.log.levels.ERROR
    )
    return
  end
  Snacks.bufdelete { force = true }
  vim.notify('Trashed ' .. file)
end

vim.keymap.set('n', '<leader>fn', function()
  local directory = os_mod.normalize_os_path(vim.fn.expand '%:p:h')
  M.prompt_path('New file: ', directory .. '/', nil, M.create_file)
end, { desc = '[F]ile [N]ew' })

vim.keymap.set(
  'n',
  '<leader>fd',
  trash_current_file,
  { desc = '[F]ile [D]elete (trash) current' }
)

vim.keymap.set('n', '<leader>fr', function()
  local source_path = vim.fn.expand '%:p'
  local directory = os_mod.normalize_os_path(vim.fn.expand '%:p:h')
  local extension = vim.fn.expand '%:e'
  local default = directory .. '/' .. '.' .. extension
  M.prompt_path(
    'Rename to: ',
    default,
    #default - #extension - 1,
    function(path) move_file(source_path, path) end
  )
end, { desc = '[F]ile [R]ename' })

vim.keymap.set('n', '<leader>fe', function()
  local source_path = vim.fn.expand '%:p'
  local default = os_mod.normalize_os_path(vim.fn.expand '%:p:r') .. '.'
  M.prompt_path(
    'Rename to: ',
    default,
    nil,
    function(path) move_file(source_path, path) end
  )
end, { desc = '[F]ile [E]xtension' })

vim.keymap.set(
  'n',
  '<leader>fm',
  function() prompt_destination_for_current_file('Move to: ', move_file) end,
  { desc = '[F]ile [M]ove' }
)

vim.keymap.set(
  'n',
  '<leader>fc',
  function() prompt_destination_for_current_file('Copy to: ', copy_file) end,
  { desc = '[F]ile [C]opy' }
)

return M
