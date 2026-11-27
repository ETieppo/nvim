vim.keymap.set('n', '\\', function()
  if not require('layout.database_manager.ui').focus() then
    vim.cmd 'Neotree reveal'
  end
end, {
  desc = 'Focus DBUI / Neotree reveal',
  silent = true,
})
