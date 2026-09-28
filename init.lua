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

local cfg = vim.fn.stdpath 'config'
local profile = require 'settings.profile'
local scan = require('utils.scan_modules_imports').scan_modules_imports

local imp = scan(cfg .. '/lua/plugins', 'plugins', {
  exclude = { ['plugins.extra'] = true },
})

if not profile.is 'minimal' then
  vim.list_extend(imp, scan(cfg .. '/lua/plugins/extra', 'plugins.extra'))
end

local dir = vim.fn.stdpath 'config' .. '/after/lsp'
local servers = {}

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
