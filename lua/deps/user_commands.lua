local profile = require 'deps.profile'

vim.api.nvim_create_user_command(
  'Maximum',
  function() profile.apply 'max' end,
  { desc = 'Switch to the full plugin profile' }
)

vim.api.nvim_create_user_command(
  'Minimal',
  function() profile.apply 'minimal' end,
  { desc = 'Switch to the minimal plugin profile' }
)

vim.api.nvim_create_user_command(
  'Profile',
  function()
    vim.notify(
      'Profile: ' .. profile.get_profile_capability(),
      vim.log.levels.INFO
    )
  end,
  { desc = 'Show the active plugin profile' }
)
