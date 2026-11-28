local DatabaseFiletypeEnum =
  require('layout.database_manager.enums').DatabaseFiletypeEnum
local DASHBOARD_CLOSING_FILETYPES = {
  'neo-tree',
  DatabaseFiletypeEnum.drawer,
  DatabaseFiletypeEnum.result,
}

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Close the dashboard when a side panel opens',
  pattern = DASHBOARD_CLOSING_FILETYPES,
  callback = function()
    vim.schedule(require('buffer.window.dashboard').close_dashboard)
  end,
})
