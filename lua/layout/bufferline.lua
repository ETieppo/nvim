local plugins = require 'deps.plugins'
local helpers = require 'utils.helpers'

---@class BufferlineElementProps
---@field name string
---@field base_name? string
---@field base? table
---@field visible? table
---@field selected? table

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
local DIAGNOSTIC_SEVERITIES = { 'error', 'warning', 'info', 'hint' }
local BOLD = { bold = true }
local ITALIC = { italic = true }
local BOLD_ITALIC = { bold = true, italic = true }

---@return BufferlineElementProps[]
local function list_elements()
  ---@type BufferlineElementProps[]
  local elements = {
    {
      name = 'buffer',
      base_name = 'background',
      base = BOLD,
      selected = BOLD_ITALIC,
    },
    { name = 'duplicate', base = ITALIC, visible = ITALIC, selected = ITALIC },
    { name = 'close_button' },
    { name = 'modified' },
  }
  for _, severity in ipairs(DIAGNOSTIC_SEVERITIES) do
    table.insert(
      elements,
      { name = severity, base = BOLD, selected = BOLD_ITALIC }
    )
    table.insert(
      elements,
      { name = severity .. '_diagnostic', selected = ITALIC }
    )
  end
  return elements
end

---@param p ThemeProps
---@return table<string, table>
local function build_highlights(p)
  local inactive = { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg }
  local active = { fg = p.ornamentActiveFg, bg = p.ornamentActiveBg }
  local highlights = {
    fill = { bg = p.bg },
    separator = { fg = p.bg, bg = p.ornamentInactiveBg },
    separator_visible = { fg = p.bg, bg = p.ornamentInactiveBg },
    separator_selected = { fg = p.bg, bg = p.ornamentActiveBg },
    indicator_selected = vim.deepcopy(active),
  }

  for _, element in ipairs(list_elements()) do
    highlights[element.base_name or element.name] =
      vim.tbl_extend('force', inactive, element.base or {})
    highlights[element.name .. '_visible'] =
      vim.tbl_extend('force', inactive, element.visible or {})
    highlights[element.name .. '_selected'] =
      vim.tbl_extend('force', active, element.selected or {})
  end
  return highlights
end

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

    return { options = options, highlights = build_highlights(p) }
  end,
}
