local plugins = require 'deps.plugins'
local os_mod = require 'deps.sys'
local treesitter = require 'core.treesitter.registry'

local LAZY_LOADED_EVENT = 'VeryLazy'
local PARSERS_UPDATE_EVENT = 'TSUpdate'

---@return string[]
local function get_parsers_to_install()
  if
    not os_mod.has_executable 'gcc' or not os_mod.has_executable 'tree-sitter'
  then
    return {}
  end
  return treesitter.get_treesitters_to_install()
end

plugins.record {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    vim.api.nvim_create_autocmd('User', {
      pattern = PARSERS_UPDATE_EVENT,
      callback = function()
        local parsers = require 'nvim-treesitter.parsers'
        for name, install_info in pairs(treesitter.get_install_infos()) do
          parsers[name] = { install_info = install_info }
        end
      end,
    })
    vim.api.nvim_create_autocmd('User', {
      pattern = LAZY_LOADED_EVENT,
      once = true,
      callback = function()
        require('nvim-treesitter').install(get_parsers_to_install())
      end,
    })
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
