local plugins = require 'deps.plugins'
local os_mod = require 'deps.sys'
local helpers = require 'utils.helpers'

local PARSERS_UPDATE_EVENT = 'TSUpdate'
local is_plugin_loaded = false

---@return string[]
local function get_parsers_to_install()
  if
    not os_mod.has_executable 'gcc' or not os_mod.has_executable 'tree-sitter'
  then
    return {}
  end
  return require('core.treesitter.registry').get_treesitters_to_install()
end

plugins.record {
  'nvim-treesitter/nvim-treesitter',
  event = { 'BufReadPre', 'BufNewFile', 'VeryLazy' },
  cmd = {
    'TSInstall',
    'TSInstallFromGrammar',
    'TSUpdate',
    'TSUninstall',
    'TSLog',
  },
  build = ':TSUpdate',
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        if not is_plugin_loaded then return end
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
  config = function()
    is_plugin_loaded = true
    vim.api.nvim_create_autocmd('User', {
      pattern = PARSERS_UPDATE_EVENT,
      callback = function()
        local parsers = require 'nvim-treesitter.parsers'
        local treesitter = require 'core.treesitter.registry'
        for name, install_info in pairs(treesitter.get_install_infos()) do
          parsers[name] = { install_info = install_info }
        end
      end,
    })
    helpers.on_very_lazy(
      function() require('nvim-treesitter').install(get_parsers_to_install()) end
    )
  end,
}
