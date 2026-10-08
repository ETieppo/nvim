require 'settings'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

local servers = {}
local dir = vim.fn.stdpath 'config' .. '/after/lsp'
local profile = require 'settings.profile'
local exclude_dirs = profile.is_min_profile() and { ['plugins.extra'] = true } or {}
local scan = require('utils.helpers').find_modules
local imp = scan('/lua/plugins', 'plugins', {
  exclude = exclude_dirs,
})

for file, kind in vim.fs.dir(dir) do
  if kind == 'file' and file:sub(-4) == '.lua' then
    servers[#servers + 1] = file:sub(1, -5)
  end
end

vim.lsp.enable(servers)
require('lazy').setup {
  spec = imp,
  change_detection = { enable = false, notify = false },
}
