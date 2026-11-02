vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'settings'
require 'utils'
require 'buffer'
require 'components.cmdline'
local helpers = require 'utils.helpers'
local lang_mod = require 'langs.core'

local exclude_dirs = {}
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local profile = require 'settings.profile'
local scan = helpers.find_modules

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  error('Error cloning lazy.nvim:\n' .. vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

if profile.is_min_profile() then exclude_dirs = { ['plugins.extra'] = true } end

local plugins = scan('/lua/plugins', 'plugins', {
  exclude = exclude_dirs,
})

lang_mod.load_langs()
vim.lsp.enable(lang_mod.get_lsps())

require('lazy').setup {
  spec = plugins,
  change_detection = { enable = false, notify = false },
}
