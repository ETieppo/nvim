local lsp = require 'core.lsp.registry'
local plugins = require 'deps.plugins'
local profile = require 'deps.profile'
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local DATA_DIRECTORY_PATTERN = '/data/'
local USELESS_DIRECTORY_PREFIX = 'useless/'
local USELESS_ENTRY_PATTERN = '^useless/[^/]+/plugin%.lua$'

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

local _plugins = plugins.get_plugins() or {}

for name, entry_type in
  vim.fs.dir(vim.fn.stdpath 'config' .. '/lua', {
    depth = math.huge,
  })
do
  if
    entry_type == 'file'
    and name:sub(-4) == '.lua'
    and name ~= 'loader.lua'
    and not name:find(DATA_DIRECTORY_PATTERN, 1, true)
    and (
      not vim.startswith(name, USELESS_DIRECTORY_PREFIX)
      or (profile.is_max_profile() and name:find(USELESS_ENTRY_PATTERN) ~= nil)
    )
  then
    require((name:sub(1, -5)):gsub('/', '.'))
  end
end

vim.lsp.enable(lsp.get_lsps())

require('lazy').setup {
  spec = _plugins,
  change_detection = { enable = false, notify = false },
}
