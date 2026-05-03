vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<A-Up>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('n', '<A-Down>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('i', '<A-Up>', '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('i', '<A-Down>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('v', '<A-Up>', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<A-Down>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('i', '<A-k>', '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('i', '<A-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = 'Open lazy' })
vim.keymap.set('n', '<leader>bd', function()
  local cur = vim.api.nvim_get_current_buf()
  local next_buf = nil
  local alt = vim.fn.bufnr '#'
  if alt > 0 and alt ~= cur and vim.fn.buflisted(alt) == 1 then
    next_buf = alt
  end
  if not next_buf then
    for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
      if info.bufnr ~= cur then
        next_buf = info.bufnr
        break
      end
    end
  end
  if next_buf then vim.api.nvim_set_current_buf(next_buf) end
  vim.cmd('bdelete ' .. cur)
end, { desc = '[B]uffer [D]elete' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- file
vim.keymap.set('n', '<leader>fn', function()
  local dir = vim.fn.expand '%:p:h'
  local path = vim.fn.input('New file: ', dir .. '/', 'file')
  if path == '' then return end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.cmd('edit ' .. path)
end, { desc = '[F]ile [N]ew' })

vim.keymap.set('n', '<leader>fd', function()
  local file = vim.fn.expand '%:p'
  if vim.fn.confirm('Delete file?\n' .. file, '&Yes\n&No', 2) == 1 then
    vim.fn.delete(file)
    vim.cmd 'bdelete!'
    print('Deleted ' .. file)
  end
end, { desc = '[F]ile [D]elete current' })

vim.keymap.set('n', '<leader>fr', function()
  local old = vim.fn.expand '%:p'
  local dir = vim.fn.expand '%:p:h'
  local ext = vim.fn.expand '%:e'
  local default = dir .. '/.' .. ext
  local move = #ext + 1
  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move), 'n', false) end)
  local new = vim.fn.input('Rename to: ', default, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
  vim.fn.rename(old, new)
  vim.cmd('edit ' .. new)
  vim.cmd 'bdelete! #'
end, { desc = '[F]ile [R]ename' })

vim.keymap.set('n', '<leader>fm', function()
  local old = vim.fn.expand '%:p'
  local name = vim.fn.expand '%:t'
  local move = #name
  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move), 'n', false) end)
  local new = vim.fn.input('Move to: ', old, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
  vim.fn.rename(old, new)
  vim.cmd('edit ' .. vim.fn.fnameescape(new))
  vim.cmd 'bdelete! #'
end, { desc = '[F]ile [M]ove' })

vim.keymap.set('n', '<leader>fc', function()
  local old = vim.fn.expand '%:p'
  local name = vim.fn.expand '%:t'
  local move_cursor = #name

  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move_cursor), 'n', false) end)

  local new = vim.fn.input('Copy to: ', old, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')

  local success = vim.loop.fs_copyfile(old, new)
  if success then
    vim.cmd('edit ' .. vim.fn.fnameescape(new))
  else
    print '\nError at file clone.'
  end
end, { desc = '[F]ile [C]opy' })

vim.keymap.set('n', '<leader>cn', function()
  local config_lua_path = vim.fn.stdpath('config') .. '/lua/'
  local path = vim.fn.input('New Lua config: ', config_lua_path, 'file')
  if path == '' then return end
  if not path:match('%.lua$') then
    path = path .. '.lua'
  end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.cmd('edit ' .. path)
end, { desc = '[C]onfig [N]ew' })


vim.keymap.set('n', '<leader>cg', function()
  require('telescope.builtin').live_grep({
    cwd = vim.fn.stdpath('config'),
    prompt_title = 'Live grep in neovim config',
  })
end, { desc = '[C]onfig [G]rep' })

-- vim.keymap.set({ 'n', 'x' }, 'j', 'gj', { silent = true })
-- vim.keymap.set({ 'n', 'x' }, 'k', 'gk', { silent = true })
-- vim.keymap.set({ 'n', 'x' }, '<Down>', 'gj', { silent = true })
-- vim.keymap.set({ 'n', 'x' }, '<Up>', 'gk', { silent = true })
