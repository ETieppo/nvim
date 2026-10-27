require 'settings'
require 'utils'
local helpers = require 'utils.helpers'

local servers = {}
local exclude_dirs = {}
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local dir = vim.fn.stdpath 'config' .. '/after/lsp'
local profile = require 'settings.profile'
local scan = helpers.find_modules

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. vim.fn.system {
      'git',
      'clone',
      '--filter=blob:none',
      '--branch=stable',
      'https://github.com/folke/lazy.nvim.git',
      lazypath,
    })
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

if profile.is_min_profile() then exclude_dirs = { ['plugins.extra'] = true } end

local plugins = scan('/lua/plugins', 'plugins', {
  exclude = exclude_dirs,
})

for file, kind in vim.fs.dir(dir) do
  if kind == 'file' and file:sub(-4) == '.lua' then
    servers[#servers + 1] = file:sub(1, -5)
  end
end

vim.lsp.enable(servers)

require('lazy').setup {
  spec = plugins,
  change_detection = { enable = false, notify = false },
}
