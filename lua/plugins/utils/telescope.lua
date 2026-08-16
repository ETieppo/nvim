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
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '--hidden',
          '--glob=!.git/',
          '--glob=!imgs/',
          '--glob=!images/',
          '--glob=!videos/',
          '--glob=!fonts/',
          '--glob=!assets/',
          '--glob=!bun.lock',
          '--glob=!package-lock.json',
          '--glob=!Cargo.lock',
          '--glob=!.angular/',
        },
      },
      pickers = {
        find_files = {
          find_command = {
            'rg',
            '--files',
            '--hidden',
            '--glob=!.git/',
            '--glob=!imgs/',
            '--glob=!images/',
            '--glob=!videos/',
            '--glob=!fonts/',
            '--glob=!assets/',
            '--glob=!bun.lock',
            '--glob=!package-lock.json',
            '--glob=!Cargo.lock',
            '--glob=!.angular/',
          },
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
