local enums = require 'buffer.enums'

---@class VirtualLinesRenderContextProps
---@field text_width integer
---@field flippable_columns_by_line table<integer, integer>
---@field layouts_by_line table<integer, DiagnosticLayoutEnum>

---@class VirtualLineGroupProps
---@field first_index integer
---@field last_index integer
---@field display_column integer

---@class DiagnosticLayoutCandidateProps
---@field layout DiagnosticLayoutEnum
---@field width integer
---@field extra_lines integer

---@class VirtualLinesExtmarkDetailsProps : vim.api.keyset.extmark_details
---@field virt_lines_overflow? string

local DiagnosticLayoutEnum = enums.DiagnosticLayoutEnum
local DIAGNOSTIC_PREFIX = '🭰'
local DIAGNOSTIC_SUFFIX = '🭵'
local DIAGNOSTIC_PREFIX_WIDTH = vim.api.nvim_strwidth(DIAGNOSTIC_PREFIX)
local DIAGNOSTIC_SUFFIX_WIDTH = vim.api.nvim_strwidth(DIAGNOSTIC_SUFFIX)
local BORDERS_WIDTH = DIAGNOSTIC_PREFIX_WIDTH + DIAGNOSTIC_SUFFIX_WIDTH + 2
local CONNECTOR_WIDTH = 6
local MINIMUM_MESSAGE_WIDTH = 20
local RIGHT_CONNECTOR_PATTERN = '^└'
local CONTINUATION_CENTER = string.rep(' ', CONNECTOR_WIDTH)
local BLANK_PATTERN = '^%s*$'
local HORIZONTAL_CONNECTOR = '─'
local VERTICAL_CONNECTOR = '│'
local UP_LEFT_CONNECTOR = '┘'
local VIRTUAL_LINES_HIGHLIGHT_PATTERN = '^DiagnosticVirtualLines'
local VIRTUAL_TEXT_HIGHLIGHT_PREFIX = 'DiagnosticVirtualText'
local QUOTED_NAME_PATTERN = '"([%w_]+)"'
local MEMBER_ACCESSOR_PATTERN = '^(%??%.)'
local NAME_END_FRONTIER = '%f[^%w_]'
local builtin_virtual_lines_handler = vim.diagnostic.handlers.virtual_lines
---@type VirtualLinesRenderContextProps|nil
local render_context = nil

---@param bufnr integer
---@return integer
local function get_text_width(bufnr)
  local win = vim.fn.bufwinid(bufnr)
  if win == -1 then win = vim.api.nvim_get_current_win() end

  local textoff = vim.fn.getwininfo(win)[1].textoff
  return vim.api.nvim_win_get_width(win) - textoff
end

---@param diagnostics vim.Diagnostic[]
---@return table<integer, integer>
local function find_flippable_columns(diagnostics)
  ---@type table<integer, integer>
  local leftmost_columns = {}
  ---@type table<integer, integer>
  local leftmost_counts = {}

  for _, diagnostic in ipairs(diagnostics) do
    local leftmost_column = leftmost_columns[diagnostic.lnum]
    if not leftmost_column or diagnostic.col < leftmost_column then
      leftmost_columns[diagnostic.lnum] = diagnostic.col
      leftmost_counts[diagnostic.lnum] = 1
    elseif diagnostic.col == leftmost_column then
      leftmost_counts[diagnostic.lnum] = leftmost_counts[diagnostic.lnum] + 1
    end
  end

  for lnum, count in pairs(leftmost_counts) do
    if count > 1 then leftmost_columns[lnum] = nil end
  end
  return leftmost_columns
end

---@param diagnostic vim.Diagnostic
---@return vim.Diagnostic
local function point_to_accessed_member(diagnostic)
  local name = diagnostic.message:match(QUOTED_NAME_PATTERN)
  if not name or not diagnostic.end_col then return diagnostic end
  if diagnostic.end_lnum and diagnostic.end_lnum ~= diagnostic.lnum then
    return diagnostic
  end

  local line = vim.api.nvim_buf_get_lines(
    diagnostic.bufnr,
    diagnostic.lnum,
    diagnostic.lnum + 1,
    false
  )[1]
  if not line then return diagnostic end

  local accessor = line
    :sub(diagnostic.end_col + 1)
    :match(MEMBER_ACCESSOR_PATTERN .. name .. NAME_END_FRONTIER)
  if not accessor then return diagnostic end

  local member_column = diagnostic.end_col + #accessor
  return vim.tbl_extend('force', diagnostic, {
    col = member_column,
    end_col = member_column + #name,
  })
end

---@param diagnostics vim.Diagnostic[]
---@return vim.Diagnostic[]
local function point_to_accessed_members(diagnostics)
  return vim.tbl_map(point_to_accessed_member, diagnostics)
end

---@param bufnr integer
---@param diagnostics vim.Diagnostic[]
---@return VirtualLinesRenderContextProps
local function create_render_context(bufnr, diagnostics)
  return {
    text_width = get_text_width(bufnr),
    flippable_columns_by_line = find_flippable_columns(diagnostics),
    layouts_by_line = {},
  }
end

---@param diagnostic vim.Diagnostic
---@return integer
local function get_display_column(diagnostic)
  return vim.api.nvim_buf_call(
    diagnostic.bufnr,
    function()
      return vim.fn.virtcol { diagnostic.lnum + 1, diagnostic.col + 1 } - 1
    end
  )
end

---@param paragraph string
---@param content_width integer
---@param lines string[]
local function wrap_paragraph(paragraph, content_width, lines)
  local line, line_width = '', 0
  for word in paragraph:gmatch '%S+' do
    local word_width = vim.api.nvim_strwidth(word)
    if line_width == 0 then
      line, line_width = word, word_width
    elseif line_width + 1 + word_width > content_width then
      table.insert(lines, line)
      line, line_width = word, word_width
    else
      line, line_width = line .. ' ' .. word, line_width + 1 + word_width
    end
  end
  table.insert(lines, line)
end

---@param message string
---@param width integer
---@return string[]
local function split_message_lines(message, width)
  local content_width = math.max(width - BORDERS_WIDTH, 1)
  ---@type string[]
  local lines = {}
  for _, paragraph in ipairs(vim.split(message, '\n')) do
    wrap_paragraph(paragraph, content_width, lines)
  end
  return lines
end

---@param message string
---@param width integer
---@return string[]|nil
local function fit_message_lines(message, width)
  local content_width = width - BORDERS_WIDTH
  if content_width < 1 then return nil end

  local lines = split_message_lines(message, width)
  for _, line in ipairs(lines) do
    if vim.api.nvim_strwidth(line) > content_width then return nil end
  end
  return lines
end

---@param lines string[]
---@return string
local function add_borders(lines)
  local block_width = 0
  for _, line in ipairs(lines) do
    block_width = math.max(block_width, vim.api.nvim_strwidth(line))
  end

  ---@type string[]
  local bordered_lines = {}
  for index, line in ipairs(lines) do
    local padding = block_width - vim.api.nvim_strwidth(line)
    bordered_lines[index] = DIAGNOSTIC_PREFIX
      .. ' '
      .. line
      .. string.rep(' ', padding)
      .. ' '
      .. DIAGNOSTIC_SUFFIX
  end
  return table.concat(bordered_lines, '\n')
end

---@param display_column integer
---@param text_width integer
---@param is_flippable boolean
---@return DiagnosticLayoutCandidateProps[]
local function build_layout_candidates(display_column, text_width, is_flippable)
  ---@type DiagnosticLayoutCandidateProps[]
  local candidates = {}
  local screen_column = display_column % text_width

  if display_column < text_width then
    table.insert(candidates, {
      layout = DiagnosticLayoutEnum.right,
      width = text_width - display_column - CONNECTOR_WIDTH,
      extra_lines = 0,
    })
  end
  if not is_flippable then return candidates end

  table.insert(candidates, {
    layout = DiagnosticLayoutEnum.left,
    width = screen_column - CONNECTOR_WIDTH + 1,
    extra_lines = 0,
  })
  table.insert(candidates, {
    layout = DiagnosticLayoutEnum.below,
    width = text_width,
    extra_lines = 1,
  })
  return candidates
end

---@param message string
---@param display_column integer
---@param text_width integer
---@param is_flippable boolean
---@return DiagnosticLayoutEnum, string[]
local function choose_layout(message, display_column, text_width, is_flippable)
  ---@type DiagnosticLayoutEnum|nil
  local best_layout = nil
  ---@type string[]|nil
  local best_lines = nil
  local best_line_count = math.huge
  local candidates =
    build_layout_candidates(display_column, text_width, is_flippable)

  for _, candidate in ipairs(candidates) do
    local lines = fit_message_lines(message, candidate.width)
    if lines and #lines + candidate.extra_lines < best_line_count then
      best_layout, best_lines = candidate.layout, lines
      best_line_count = #lines + candidate.extra_lines
    end
  end

  if best_layout and best_lines then return best_layout, best_lines end
  return DiagnosticLayoutEnum.right,
    split_message_lines(
      message,
      math.max(
        text_width - display_column - CONNECTOR_WIDTH,
        MINIMUM_MESSAGE_WIDTH
      )
    )
end

---@param diagnostic vim.Diagnostic
---@return string
local function wrap_virtual_diagnostic(diagnostic)
  local context = render_context or create_render_context(diagnostic.bufnr, {})
  local is_flippable = context.flippable_columns_by_line[diagnostic.lnum]
    == diagnostic.col
  local layout, lines = choose_layout(
    diagnostic.message,
    get_display_column(diagnostic),
    context.text_width,
    is_flippable
  )

  if layout ~= DiagnosticLayoutEnum.right then
    context.layouts_by_line[diagnostic.lnum] = layout
  end
  return add_borders(lines)
end

---@param virtual_line [string, any][]
---@return integer|nil
local function measure_blank_left_side(virtual_line)
  local width = 0
  for index = 1, #virtual_line - 2 do
    local text = virtual_line[index][1]
    if not text:find(BLANK_PATTERN) then return nil end
    width = width + vim.api.nvim_strwidth(text)
  end
  return width
end

---@param virtual_lines [string, any][][]
---@return VirtualLineGroupProps|nil
local function find_leftmost_group(virtual_lines)
  ---@type VirtualLineGroupProps|nil
  local leftmost_group = nil
  ---@type VirtualLineGroupProps|nil
  local current_group = nil

  for index, virtual_line in ipairs(virtual_lines) do
    local center = virtual_line[#virtual_line - 1]
    local left_width = #virtual_line >= 2
      and measure_blank_left_side(virtual_line)

    if not center or not left_width then
      current_group = nil
    elseif center[1]:find(RIGHT_CONNECTOR_PATTERN) then
      current_group = {
        first_index = index,
        last_index = index,
        display_column = left_width,
      }
      leftmost_group = current_group
    elseif
      center[1] == CONTINUATION_CENTER
      and current_group
      and current_group.display_column == left_width
    then
      current_group.last_index = index
    else
      current_group = nil
    end
  end
  return leftmost_group
end

---@param virtual_lines [string, any][][]
---@param group VirtualLineGroupProps
---@return [string, any][]
local function get_group_messages(virtual_lines, group)
  ---@type [string, any][]
  local messages = {}
  for index = group.first_index, group.last_index do
    local virtual_line = virtual_lines[index]
    table.insert(messages, virtual_line[#virtual_line])
  end
  return messages
end

---@param messages [string, any][]
---@param column integer
---@param connector_highlight any
---@return [string, any][][]
local function build_left_layout(messages, column, connector_highlight)
  local block_width = vim.api.nvim_strwidth(messages[1][1])
  local block_start = math.max(column - CONNECTOR_WIDTH + 1 - block_width, 0)
  local horizontal_length = math.max(column - block_start - block_width - 1, 0)

  ---@type [string, any][][]
  local rendered_lines = {}
  for index, message in ipairs(messages) do
    local rendered_line = { { string.rep(' ', block_start), '' }, message }
    if index == 1 then
      table.insert(rendered_line, {
        ' '
          .. string.rep(HORIZONTAL_CONNECTOR, horizontal_length)
          .. UP_LEFT_CONNECTOR,
        connector_highlight,
      })
    end
    table.insert(rendered_lines, rendered_line)
  end
  return rendered_lines
end

---@param messages [string, any][]
---@param column integer
---@param connector_highlight any
---@return [string, any][][]
local function build_below_layout(messages, column, connector_highlight)
  local connector = column > 0
      and string.rep(HORIZONTAL_CONNECTOR, column) .. UP_LEFT_CONNECTOR
    or VERTICAL_CONNECTOR

  ---@type [string, any][][]
  local rendered_lines = { { { connector, connector_highlight } } }
  for _, message in ipairs(messages) do
    table.insert(rendered_lines, { message })
  end
  return rendered_lines
end

---@param virtual_lines [string, any][][]
---@param layout DiagnosticLayoutEnum
---@param text_width integer
---@return [string, any][][]
local function apply_layout(virtual_lines, layout, text_width)
  local group = find_leftmost_group(virtual_lines)
  if not group then return virtual_lines end

  local first_line = virtual_lines[group.first_index]
  local connector_highlight = first_line[#first_line - 1][2]
  local messages = get_group_messages(virtual_lines, group)
  local column = group.display_column % text_width
  local rendered_lines = layout == DiagnosticLayoutEnum.left
      and build_left_layout(messages, column, connector_highlight)
    or build_below_layout(messages, column, connector_highlight)

  ---@type [string, any][][]
  local result = {}
  for index = 1, group.first_index - 1 do
    table.insert(result, virtual_lines[index])
  end
  vim.list_extend(result, rendered_lines)
  for index = group.last_index + 1, #virtual_lines do
    table.insert(result, virtual_lines[index])
  end
  return result
end

---@param virtual_lines [string, any][][]
local function highlight_messages(virtual_lines)
  for _, virtual_line in ipairs(virtual_lines) do
    local message_chunk = virtual_line[#virtual_line]
    if message_chunk and type(message_chunk[2]) == 'string' then
      message_chunk[2] = message_chunk[2]:gsub(
        VIRTUAL_LINES_HIGHLIGHT_PATTERN,
        VIRTUAL_TEXT_HIGHLIGHT_PREFIX
      )
    end
  end
end

---@param namespace integer
---@param bufnr integer
---@param context VirtualLinesRenderContextProps
local function render_virtual_lines_messages(namespace, bufnr, context)
  ---@type integer|nil
  local virtual_lines_namespace =
    vim.diagnostic.get_namespace(namespace).user_data.virt_lines_ns
  if not virtual_lines_namespace or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    virtual_lines_namespace,
    0,
    -1,
    { details = true }
  )

  for _, extmark in ipairs(extmarks) do
    ---@type integer, integer, integer, VirtualLinesExtmarkDetailsProps
    local id, row, col, details = unpack(extmark)
    local virtual_lines = details.virt_lines or {}
    local layout = context.layouts_by_line[row]

    highlight_messages(virtual_lines)
    if layout then
      virtual_lines = apply_layout(virtual_lines, layout, context.text_width)
    end

    vim.api.nvim_buf_set_extmark(bufnr, virtual_lines_namespace, row, col, {
      id = id,
      virt_lines = virtual_lines,
      virt_lines_overflow = details.virt_lines_overflow,
    })
  end
end

vim.diagnostic.handlers.virtual_lines = {
  show = function(namespace, bufnr, diagnostics, opts)
    local pointed_diagnostics = point_to_accessed_members(diagnostics)
    local context = create_render_context(bufnr, pointed_diagnostics)
    render_context = context
    builtin_virtual_lines_handler.show(
      namespace,
      bufnr,
      pointed_diagnostics,
      opts
    )
    render_context = nil
    render_virtual_lines_messages(namespace, bufnr, context)
  end,
  hide = builtin_virtual_lines_handler.hide,
}

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = {
    format = wrap_virtual_diagnostic,
  },
  severity_sort = true,
  underline = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.WARN] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.HINT] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.INFO] = DIAGNOSTIC_PREFIX,
    },
  },
}
