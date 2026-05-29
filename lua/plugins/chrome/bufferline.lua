return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = {
    options = {
      mode = 'buffers',
      separator_style = 'slant',
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diag)
        local icons = { error = ' ', warning = ' ', info = ' ' }
        local parts = {}
        for kind, icon in pairs(icons) do
          if (diag[kind] or 0) > 0 then
            parts[#parts + 1] = icon .. diag[kind]
          end
        end
        return table.concat(parts, ' ')
      end,
      offsets = {
        {
          filetype = 'neo-tree',
          text = '',
          highlight = 'BufferLineOffsetSeparator',
          separator = true,
        },
      },
    },
    highlights = {
      fill = { bg = '#060609' },
      background = { fg = '#545470', bg = '#08080b' },
      buffer_selected = { fg = '#c5cae9', bg = '#0a0a0d', bold = true },
      buffer_visible = { fg = '#787c99', bg = '#08080b' },
      close_button = { fg = '#545470', bg = '#08080b' },
      close_button_selected = { fg = '#787c99', bg = '#0a0a0d' },
      tab_selected = { fg = '#c5cae9', bg = '#0a0a0d', bold = true },
      tab = { fg = '#545470', bg = '#08080b' },
      tab_close = { fg = '#545470', bg = '#060609' },
      separator = { fg = '#060609', bg = '#08080b' },
      separator_selected = { fg = '#060609', bg = '#0a0a0d' },
      separator_visible = { fg = '#060609', bg = '#08080b' },
      indicator_selected = { fg = '#702ded', bg = '#0a0a0d' },
      modified = { fg = '#7aa2f7', bg = '#08080b' },
      modified_selected = { fg = '#7aa2f7', bg = '#0a0a0d' },
      diagnostic = { fg = '#545470', bg = '#08080b' },
      diagnostic_selected = { fg = '#a9b1d6', bg = '#0a0a0d' },
      error = { fg = '#db4b4b', bg = '#08080b' },
      error_selected = { fg = '#db4b4b', bg = '#0a0a0d' },
      warning = { fg = '#e0af68', bg = '#08080b' },
      warning_selected = { fg = '#e0af68', bg = '#0a0a0d' },
      info = { fg = '#0db9d7', bg = '#08080b' },
      info_selected = { fg = '#0db9d7', bg = '#0a0a0d' },
    },
  },
}
