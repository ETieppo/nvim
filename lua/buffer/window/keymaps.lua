local WINDOW_FOCUS_DIRECTIONS = {
  h = 'left',
  j = 'lower',
  k = 'upper',
  l = 'right',
}

for key, direction in pairs(WINDOW_FOCUS_DIRECTIONS) do
  vim.keymap.set(
    'n',
    '<M-D-' .. key .. '>',
    '<C-w>' .. key,
    { desc = 'Focus ' .. direction .. ' window' }
  )
end
