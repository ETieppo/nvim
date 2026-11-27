require 'layout.toast.notify'
require 'layout.toast.messages'
require 'deps.nvim_deps'
local plugins = require 'deps.plugins'
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local LUA_DIRECTORY = vim.fn.stdpath 'config' .. '/lua'
local DATA_DIRECTORY_PATTERN = '/data/'
local PLUGIN_FILE_NAME = 'plugin.lua'
local SERVERS_DIRECTORY_PATTERN = '^servers/'
local DEFERRED_LOAD_EVENTS = {
  'BufReadPre',
  'BufNewFile',
  'StdinReadPre',
  'CmdUndefined',
}
local min_nvim_version = 11
---@type string[]
local server_modules = {}
---@type string[]
local deferred_modules = {}
local deferred_group = vim.api.nvim_create_augroup('loader-deferred', {})

local function load_deferred_modules()
  vim.api.nvim_del_augroup_by_id(deferred_group)
  for _, module_name in ipairs(server_modules) do
    require(module_name)
  end
  require('core.lang.registry').apply_filetypes()
  require('core.treesitter.registry').apply_language_filetypes()
  require('core.lsp.registry').enable_lsps()
  for _, module_name in ipairs(deferred_modules) do
    require(module_name)
  end
end

if vim.fn.has('nvim-0.' .. min_nvim_version) == 0 then
  print(
    'Nvim version not supported (>='
      .. min_nvim_version
      .. ')\nCowardly refusing to boot'
  )
  return
end

if not vim.uv.fs_stat(lazypath) then
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

vim.opt.rtp:prepend(lazypath)

for name, entry_type in vim.fs.dir(LUA_DIRECTORY, { depth = math.huge }) do
  if
    entry_type == 'file'
    and name:sub(-4) == '.lua'
    and name ~= 'loader.lua'
    and not name:find(DATA_DIRECTORY_PATTERN, 1, true)
  then
    local module_name = (name:sub(1, -5):gsub('/', '.'))
    if vim.fs.basename(name) == PLUGIN_FILE_NAME then
      require(module_name)
    elseif name:find(SERVERS_DIRECTORY_PATTERN) then
      server_modules[#server_modules + 1] = module_name
    else
      deferred_modules[#deferred_modules + 1] = module_name
    end
  end
end

vim.api.nvim_create_autocmd(DEFERRED_LOAD_EVENTS, {
  group = deferred_group,
  once = true,
  callback = load_deferred_modules,
})
vim.api.nvim_create_autocmd('User', {
  group = deferred_group,
  pattern = 'VeryLazy',
  once = true,
  callback = load_deferred_modules,
})
vim.api.nvim_create_autocmd('VimEnter', {
  group = deferred_group,
  once = true,
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then load_deferred_modules() end
  end,
})

require('lazy').setup {
  spec = plugins.get_plugins(),
  change_detection = { enable = false, notify = false },
}
