local plugins = require 'deps.plugins'
local os_mod = require 'deps.sys'
local treesitter= require 'core.treesitter.registry'

local ensure_installed = os_mod.has_executable 'gcc'
    and os_mod.has_executable 'tree-sitter'
    and treesitter.get_treesitters_to_install()
  or {}

plugins.record {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').install(ensure_installed)
    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        pcall(vim.treesitter.start)
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
