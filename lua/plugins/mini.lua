return {
  'nvim-mini/mini.nvim',
  config = function()
    require('mini.ai').setup { n_lines = 500 }
    require('mini.surround').setup()
    require('mini.tabline').setup()
    require('mini.icons').setup()
    require('mini.snippets').setup()
    require('mini.sessions').setup()
    require('mini.statusline').setup {
      use_icons = vim.g.have_nerd_font,
      section_location = function() return '%2l:%-2v' end,
    }
  end,
}
