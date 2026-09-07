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
        fill = { bg = p.bg0 },
        background = { fg = p.inactiveFg, bg = p.inactiveBg, bold = true },
        buffer_visible = { fg = p.inactiveFg, bg = p.inactiveBg },
        buffer_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          bold = true,
          italic = true,
        },
        duplicate = { fg = p.inactiveFg, bg = p.inactiveBg, italic = true },
        duplicate_visible = {
          fg = p.inactiveFg,
          bg = p.inactiveBg,
          italic = true,
        },
        duplicate_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          italic = true,
        },
        separator = { fg = p.bg0, bg = p.inactiveBg },
        separator_visible = { fg = p.bg0, bg = p.inactiveBg },
        separator_selected = { fg = p.bg0, bg = p.activeBg },
        close_button = { fg = p.inactiveFg, bg = p.inactiveBg },
        close_button_visible = { fg = p.inactiveFg, bg = p.inactiveBg },
        close_button_selected = { fg = p.activeFg, bg = p.activeBg },
        modified = { fg = p.inactiveFg, bg = p.inactiveBg },
        modified_visible = { fg = p.inactiveFg, bg = p.inactiveBg },
        modified_selected = { fg = p.activeFg, bg = p.activeBg },
        indicator_selected = { fg = p.activeFg, bg = p.activeBg },
        error = { fg = p.errorFg, bg = p.errorBg, bold = true },
        error_visible = { fg = p.errorFg, bg = p.errorBg },
        error_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          bold = true,
          italic = true,
        },
        error_diagnostic = { fg = p.errorFg, bg = p.errorBg },
        error_diagnostic_visible = { fg = p.errorFg, bg = p.errorBg },
        error_diagnostic_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          italic = true,
        },
        warning = { fg = p.warnFg, bg = p.warnBg, bold = true },
        warning_visible = { fg = p.warnFg, bg = p.warnBg },
        warning_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          bold = true,
          italic = true,
        },
        warning_diagnostic = { fg = p.warnFg, bg = p.warnBg },
        warning_diagnostic_visible = { fg = p.warnFg, bg = p.warnBg },
        warning_diagnostic_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          italic = true,
        },
        info = { fg = p.infoFg, bg = p.infoBg, bold = true },
        info_visible = { fg = p.infoFg, bg = p.infoBg },
        info_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          bold = true,
          italic = true,
        },
        info_diagnostic = { fg = p.infoFg, bg = p.infoBg },
        info_diagnostic_visible = { fg = p.infoFg, bg = p.infoBg },
        info_diagnostic_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          italic = true,
        },
        hint = { fg = p.hintFg, bg = p.hintBg, bold = true },
        hint_visible = { fg = p.hintFg, bg = p.hintBg },
        hint_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          bold = true,
          italic = true,
        },
        hint_diagnostic = { fg = p.hintFg, bg = p.hintBg },
        hint_diagnostic_visible = { fg = p.hintFg, bg = p.hintBg },
        hint_diagnostic_selected = {
          fg = p.activeFg,
          bg = p.activeBg,
          italic = true,
        },
      },
    }
  end,
}
