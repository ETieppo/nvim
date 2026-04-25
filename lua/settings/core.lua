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
vim.o.cmdheight = 1
vim.o.cmdheight = 0
vim.o.background = 'dark'

vim.opt.statuscolumn = '%s%{v:lnum} %{v:relnum} '
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.virtualedit = 'onemore'
vim.opt.formatoptions:remove { 'c', 'r', 'o' }
vim.opt.termguicolors = true
vim.opt.showbreak = '↪ '
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.relativenumber = true
vim.opt.listchars = { tab = '  ', trail = '·', nbsp = '␣' }
vim.opt.fillchars:append { eob = ' ' }
vim.opt.shortmess:append 'W'

vim.api.nvim_set_hl(0, 'Comment', { italic = true })

vim.cmd 'syntax on'
vim.cmd 'filetype plugin indent on'
vim.cmd 'autocmd BufRead,BufNewFile *.hurl setfiletype sh'

vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.cmd.colorscheme 'blackberry'
vim.g.neovide_line_height_plus = 15
