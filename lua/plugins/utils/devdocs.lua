return {
  'emmanueltouzery/apidocs.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
  },
  cmd = { 'ApidocsSearch', 'ApidocsInstall', 'ApidocsOpen', 'ApidocsSelect', 'ApidocsUninstall' },
  config = function()
    local apidocs = require 'apidocs'
    apidocs.setup()

    vim.schedule(
      function()
        apidocs.ensure_install {
          'rust',
          'angular',
          'typescript',
          'openjdk~21',
          'tailwindcss',
          'c',
        }
      end
    )
  end,
  keys = {
    { '<leader>sad', '<cmd>ApidocsOpen<cr>', desc = 'Search Api Doc' },
  },
}
