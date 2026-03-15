return {
  'emmanueltouzery/apidocs.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
  },
  cmd = { 'ApidocsSearch', 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSelect', 'ApidocsUninstall' },
  config = function()
    require('apidocs').setup()
    require('apidocs').ensure_install {
      'rust',
      'angular',
      'typescript',
      'openjdk~25',
      'tailwindcss',
      'c',
    }
  end,
  keys = {
    { '<leader>sad', '<cmd>ApidocsOpen<cr>', desc = 'Search Api Doc' },
  },
}
