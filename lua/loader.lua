require 'layout.toast.notify'
local lsp = require 'core.lsp.registry'
local plugins = require 'deps.plugins'
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local DATA_DIRECTORY_PATTERN = '/data/'
local min_nvim_version = 11

if vim.version().minor < min_nvim_version then
  print(
    'Nvim version not supported (>='
      .. min_nvim_version
      .. ')\nCowardly refusing to boot'
  )
  return
end

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.notify.info 'No lazy.vim installed, installing...'
  local clone_out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. clone_out)
  else
    vim.notify.success 'lazy.vim successfully installed!'
  end
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
  then
    require((name:sub(1, -5)):gsub('/', '.'))
  end
end

vim.lsp.enable(lsp.get_lsps())

require('lazy').setup {
  spec = _plugins,
  change_detection = { enable = false, notify = false },
}
