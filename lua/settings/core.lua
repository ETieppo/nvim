vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = ''
vim.o.showmode = false
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.messagesopt = 'wait:500,history:500'
vim.o.cmdheight = 1

vim.opt.termguicolors = true
vim.opt.showbreak = '↪ '
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.relativenumber = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars:append { eob = ' ' }
vim.opt.shortmess:append 'W'

vim.api.nvim_set_hl(0, 'Comment', { italic = true })
