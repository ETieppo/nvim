local profile = require 'deps.profile'

if profile.is_max_profile() then
  vim.keymap.set('n', '<leader>dbt', function()
    local ok, dbui = pcall(require, 'layout.database_manager.ui')
    if not ok then
      vim.notify("Set 'Max' profile to use dbui", vim.log.levels.WARN)
      return
    end

    dbui.toggle()
  end, { desc = '[D]ata [B]ase [T]oggle' })

  vim.keymap.set(
    'n',
    '<leader>dbcn',
    '<cmd>DBUIAddConnection<CR>',
    { desc = '[D]ata [B]ase [C]onnection [N]ew' }
  )
end
