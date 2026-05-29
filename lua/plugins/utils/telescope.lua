return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
  },
  enabled = true,
  event = 'VimEnter',
  config = function()
    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
          'node_modules/',
          '.git/',
          'dist/',
          'target/',
          'Cargo.lock',
          '.DS_Store',
          'bin/',
          'build/',
          '.gradle/',
          '.metadata/',
          'gradle/',
          'jdt.ls-java-project/',
          '.godot/',
          '.angular',
          '.zig-cache',
          'zig-out',
        },
      },
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
  end,
}
