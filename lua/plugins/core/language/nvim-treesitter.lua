local os_mod = require 'utils.os_mod'
local lang_mod = require 'utils.lang_mod'

local ensure_installed = os_mod.has_deps 'gcc'
    and os_mod.has_deps 'tree-sitter'
    and lang_mod.install_lang_treesitters
  or {}

return {
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
