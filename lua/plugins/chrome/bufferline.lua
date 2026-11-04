---@module 'lazy'
---@type LazySpec
return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = function()
    local p = require('settings.theme').get_theme_colors()

    local options = {
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
    }

    if not p then return { options = options } end

    return {
      options = options,
      highlights = {
        fill = { bg = p.bg },
        background = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        buffer_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        buffer_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        duplicate = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          italic = true,
        },
        duplicate_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          italic = true,
        },
        duplicate_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          italic = true,
        },
        separator = { fg = p.bg, bg = p.ornamentInactiveBg },
        separator_visible = { fg = p.bg, bg = p.ornamentInactiveBg },
        separator_selected = { fg = p.bg, bg = p.ornamentActiveBg },
        close_button = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg },
        close_button_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        close_button_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
        },
        modified = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg },
        modified_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        modified_selected = { fg = p.ornamentActiveFg, bg = p.ornamentActiveBg },
        indicator_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
        },
        error = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        error_visible = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg },
        error_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        error_diagnostic = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        error_diagnostic_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        error_diagnostic_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          italic = true,
        },
        warning = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        warning_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        warning_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        warning_diagnostic = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        warning_diagnostic_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        warning_diagnostic_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          italic = true,
        },
        info = {
          fg = p.inactiveOrnamentFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        info_visible = { fg = p.inactiveOrnamentFg, bg = p.ornamentInactiveBg },
        info_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        info_diagnostic = {
          fg = p.inactiveOrnamentFg,
          bg = p.ornamentInactiveBg,
        },
        info_diagnostic_visible = {
          fg = p.inactiveOrnamentFg,
          bg = p.ornamentInactiveBg,
        },
        info_diagnostic_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          italic = true,
        },
        hint = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        hint_visible = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg },
        hint_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        hint_diagnostic = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        hint_diagnostic_visible = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        hint_diagnostic_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          italic = true,
        },
      },
    }
  end,
}
