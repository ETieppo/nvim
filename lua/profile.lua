local M = {}
local statefile = vim.fs.joinpath(vim.fn.stdpath 'state', 'profile')

function M.name()
  if vim.fn.filereadable(statefile) == 0 then return 'minimal' end
  local lines = vim.fn.readfile(statefile)
  local name = (lines[1] and vim.trim(lines[1])) or ''
  return name ~= '' and name or 'max'
end

function M.is(p) return M.name() == p end

local function apply(name)
  if name == 'minimal' then
    vim.fn.delete(statefile)
  else
    vim.fn.writefile({ name }, statefile)
  end
  vim.schedule(function()
    vim.cmd 'silent! wall'
    vim.cmd 'restart'
  end)
end

vim.api.nvim_create_user_command(
  'Maximum',
  function() apply 'max' end,
  { desc = 'Switch to the full plugin profile' }
)

vim.api.nvim_create_user_command(
  'Minimal',
  function() apply 'minimal' end,
  { desc = 'Switch to the minimal plugin profile' }
)

vim.api.nvim_create_user_command(
  'Profile',
  function() vim.notify('Profile: ' .. M.name(), vim.log.levels.INFO) end,
  { desc = 'Show the active plugin profile' }
)

return M
