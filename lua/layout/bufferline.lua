local plugins = require 'deps.plugins'
local helpers = require 'utils.helpers'

---@class DiagnosticIndicatorIconProps
---@field severity string
---@field icon string

---@type DiagnosticIndicatorIconProps[]
local DIAGNOSTIC_INDICATOR_ICONS = {
  { severity = 'error', icon = ' ' },
  { severity = 'warning', icon = ' ' },
  { severity = 'info', icon = ' ' },
}
local SELECTED_BUFFER_BACKGROUND = {
  bg = { attribute = 'bg', highlight = 'BufferLineBufferSelected' },
}

helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-l>',
  '<cmd>BufferLineCycleNext<CR>',
  { desc = 'Next buffer' }
)
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-h>',
  '<cmd>BufferLineCyclePrev<CR>',
  { desc = 'Previous buffer' }
)
vim.keymap.set(
  'n',
  '<leader>bod',
  '<cmd>BufferLineCloseOthers<CR>',
  { desc = '[B]uffer [O]thers [D]elete' }
)

---@module 'lazy'
---@type LazySpec
plugins.record {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = { 'DaikyXendo/nvim-material-icon' },
  event = 'VeryLazy',
  opts = function()
    local p = require('theme.loader').get_theme_colors()
    ---@cast p -nil

    local options = {
      mode = 'buffers',
      separator_style = 'slant',
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = true,
      diagnostics = 'nvim_lsp',
      diagnostics_indicator = function(_, _, diagnostics_count)
        ---@type string[]
        local parts = {}
        for _, indicator in ipairs(DIAGNOSTIC_INDICATOR_ICONS) do
          local count = diagnostics_count[indicator.severity] or 0
          if count > 0 then parts[#parts + 1] = indicator.icon .. count end
        end
        return table.concat(parts, ' ')
      end,
      offsets = {
        {
          filetype = 'neo-tree',
          text = '',
          highlight = {
            buffer_selected = SELECTED_BUFFER_BACKGROUND,
            buffer_visible = SELECTED_BUFFER_BACKGROUND,
            background = SELECTED_BUFFER_BACKGROUND,
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
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
          bold = true,
        },
        info_visible = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg },
        info_selected = {
          fg = p.ornamentActiveFg,
          bg = p.ornamentActiveBg,
          bold = true,
          italic = true,
        },
        info_diagnostic = {
          fg = p.ornamentInactiveFg,
          bg = p.ornamentInactiveBg,
        },
        info_diagnostic_visible = {
          fg = p.ornamentInactiveFg,
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
