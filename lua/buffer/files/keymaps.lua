local helpers = require 'buffer.files.helpers'
local os_mod = require 'deps.sys'

vim.keymap.set('n', '<leader>fn', function()
  local directory = os_mod.normalize_os_path(vim.fn.expand '%:p:h')
  helpers.prompt_path('New file: ', directory .. '/', nil, helpers.create_file)
end, { desc = '[F]ile [N]ew' })

vim.keymap.set(
  'n',
  '<leader>fd',
  helpers.trash_current_file,
  { desc = '[F]ile [D]elete (trash) current' }
)

vim.keymap.set('n', '<leader>fr', function()
  local source_path = vim.fn.expand '%:p'
  local directory = os_mod.normalize_os_path(vim.fn.expand '%:p:h')
  local extension = vim.fn.expand '%:e'
  local default = directory .. '/' .. '.' .. extension
  helpers.prompt_path(
    'Rename to: ',
    default,
    #default - #extension - 1,
    function(path) helpers.move_file(source_path, path) end
  )
end, { desc = '[F]ile [R]ename' })

vim.keymap.set('n', '<leader>fe', function()
  local source_path = vim.fn.expand '%:p'
  local default = os_mod.normalize_os_path(vim.fn.expand '%:p:r') .. '.'
  helpers.prompt_path(
    'Rename to: ',
    default,
    nil,
    function(path) helpers.move_file(source_path, path) end
  )
end, { desc = '[F]ile [E]xtension' })

vim.keymap.set(
  'n',
  '<leader>fm',
  function()
    helpers.prompt_destination_for_current_file('Move to: ', helpers.move_file)
  end,
  { desc = '[F]ile [M]ove' }
)

vim.keymap.set(
  'n',
  '<leader>fc',
  function()
    helpers.prompt_destination_for_current_file('Copy to: ', helpers.copy_file)
  end,
  { desc = '[F]ile [C]opy' }
)
