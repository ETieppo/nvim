local p = require 'blackberry.palette'
local activeBg = p.cyan
local inactiveBg = p.darkRed

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = {
    highlights = {
      background = { fg = p.bg1, bg = inactiveBg, bold = true },
      buffer_selected = {
        fg = p.bg1,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      duplicate = { fg = p.bg1, bg = inactiveBg, italic = true },
      duplicate_selected = { fg = p.bg1, bg = activeBg, italic = true },
      duplicate_visible = { fg = p.darkRed, bg = p.bg5, italic = true },
      buffer_visible = { fg = p.darkRed, bg = p.bg5 },
      fill = { bg = p.bg0 },
      separator = { fg = p.bg5, bg = inactiveBg },
      separator_selected = { fg = p.bg5, bg = activeBg },
      separator_visible = { fg = p.bg5, bg = p.bg5 },
      close_button = { fg = p.darkRed, bg = p.bg5 },
      close_button_selected = { fg = p.bg5, bg = p.darkRed },
      modified = { fg = p.bg1, bg = inactiveBg },
      modified_selected = { fg = p.bg1, bg = activeBg },
      indicator_selected = { fg = p.darkRed, bg = p.darkRed },
      error = { fg = p.bg1, bg = inactiveBg },
      error_visible = { fg = p.darkRed, bg = p.bg5 },
      error_selected = { fg = p.bg1, bg = activeBg },
      error_diagnostic = { fg = p.bg1, bg = inactiveBg },
      error_diagnostic_visible = { fg = p.darkRed, bg = p.bg5 },
      error_diagnostic_selected = { fg = p.bg1, bg = activeBg },
      warning = { fg = p.bg1, bg = inactiveBg },
      warning_visible = { fg = p.darkRed, bg = p.bg5 },
      warning_selected = { fg = p.bg1, bg = activeBg },
      warning_diagnostic = { fg = p.bg1, bg = inactiveBg },
      warning_diagnostic_visible = { fg = p.darkRed, bg = p.bg5 },
      warning_diagnostic_selected = { fg = p.bg1, bg = activeBg },
    },
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
          highlight = {
            buffer_selected = {
              bg = { attribute = 'bg', highlight = 'BufferLineBufferSelected' },
            },
            buffer_visible = {
              bg = { attribute = 'bg', highlight = 'BufferLineBufferSelected' },
            },
            background = {
              bg = { attribute = 'bg', highlight = 'BufferLineBufferSelected' },
            },
          },
          separator = true,
        },
      },
    },
  },
}
