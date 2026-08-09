local p = require 'blackberry.palette'

-- estados do buffer (sem diagnóstico)
local activeFg = p.cyan
local activeBg = p.cyanDim
local inactiveFg = p.darkRed
local inactiveBg = p.darkRedDim

-- diagnósticos: fg = cor do nível, bg = fundo escuro do nível
local errorFg = p.error_
local errorBg = p.bgRed
local warnFg = p.warning
local warnBg = p.bgYellow
local infoFg = p.info
local infoBg = p.bgBlue
local hintFg = p.hint
local hintBg = p.bgTeal -- << adicionar no palette (ver nota)

return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  event = 'VeryLazy',
  opts = {
    highlights = {
      fill = { bg = p.bg0 },
      background = { fg = inactiveFg, bg = inactiveBg, bold = true },
      buffer_visible = { fg = inactiveFg, bg = inactiveBg },
      buffer_selected = {
        fg = activeFg,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      duplicate = { fg = inactiveFg, bg = inactiveBg, italic = true },
      duplicate_visible = { fg = inactiveFg, bg = inactiveBg, italic = true },
      duplicate_selected = { fg = activeFg, bg = activeBg, italic = true },
      separator = { fg = p.bg0, bg = inactiveBg },
      separator_visible = { fg = p.bg0, bg = inactiveBg },
      separator_selected = { fg = p.bg0, bg = activeBg },
      close_button = { fg = inactiveFg, bg = inactiveBg },
      close_button_visible = { fg = inactiveFg, bg = inactiveBg },
      close_button_selected = { fg = activeFg, bg = activeBg },
      modified = { fg = inactiveFg, bg = inactiveBg },
      modified_visible = { fg = inactiveFg, bg = inactiveBg },
      modified_selected = { fg = activeFg, bg = activeBg },
      indicator_selected = { fg = activeFg, bg = activeBg },
      error = { fg = errorFg, bg = errorBg, bold = true },
      error_visible = { fg = errorFg, bg = errorBg },
      error_selected = {
        fg = errorFg,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      error_diagnostic = { fg = errorFg, bg = errorBg },
      error_diagnostic_visible = { fg = errorFg, bg = errorBg },
      error_diagnostic_selected = { fg = errorFg, bg = activeBg, italic = true },
      warning = { fg = warnFg, bg = warnBg, bold = true },
      warning_visible = { fg = warnFg, bg = warnBg },
      warning_selected = {
        fg = warnFg,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      warning_diagnostic = { fg = warnFg, bg = warnBg },
      warning_diagnostic_visible = { fg = warnFg, bg = warnBg },
      warning_diagnostic_selected = {
        fg = warnFg,
        bg = activeBg,
        italic = true,
      },
      info = { fg = infoFg, bg = infoBg, bold = true },
      info_visible = { fg = infoFg, bg = infoBg },
      info_selected = {
        fg = infoFg,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      info_diagnostic = { fg = infoFg, bg = infoBg },
      info_diagnostic_visible = { fg = infoFg, bg = infoBg },
      info_diagnostic_selected = { fg = infoFg, bg = activeBg, italic = true },
      hint = { fg = hintFg, bg = hintBg, bold = true },
      hint_visible = { fg = hintFg, bg = hintBg },
      hint_selected = {
        fg = hintFg,
        bg = activeBg,
        bold = true,
        italic = true,
      },
      hint_diagnostic = { fg = hintFg, bg = hintBg },
      hint_diagnostic_visible = { fg = hintFg, bg = hintBg },
      hint_diagnostic_selected = { fg = hintFg, bg = activeBg, italic = true },
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
