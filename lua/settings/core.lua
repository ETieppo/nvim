vim.g.have_nerd_font = true

vim.o.number = true
vim.o.mouse = nil
vim.o.showmode = false
vim.o.breakindent = true
vim.opt.showbreak = '↪ '
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

vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.wrap = true
vim.opt.relativenumber = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars:append { eob = ' ' }

-- options.lua / init.lua
vim.opt.termguicolors = true

-- evita o "Press ENTER"
vim.o.messagesopt = 'wait:500,history:500'

-- mais espaço para mensagens sem hit-enter
vim.o.cmdheight = 1
-- se ainda insistir em aparecer, teste 2
-- vim.o.cmdheight = 2

-- reduz mensagens chatas de escrita
vim.opt.shortmess:append 'W'
