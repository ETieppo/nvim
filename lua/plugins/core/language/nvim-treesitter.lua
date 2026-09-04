local os = require 'utils.os'

local ensure_installed = os.has_deps 'gcc'
    and os.has_deps 'tree-sitter'
    and {
      'html',
      'angular',
      'css',
      'sql',
      'tsx',
      'javascript',
      'typescript',
      'toml',
      'zig',
      'rust',
      'lua',
      'markdown',
      'markdown_inline',
      'vim',
      'vimdoc',
      'query',
      'python',
      'asm',
    }
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
