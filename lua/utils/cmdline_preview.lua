---@class CmdlinePreviewWindowOptionsProps
---@field conceallevel integer
---@field concealcursor string

---@class CmdlinePreviewProps
---@field source_window integer
---@field source_buffer integer
---@field cmdline_type string
---@field saved_view vim.fn.winsaveview.ret
---@field match_ids integer[]
---@field saved_window_options? CmdlinePreviewWindowOptionsProps

---@class SubstituteProps
---@field pattern string
---@field replacement string
---@field is_global boolean
---@field is_count_only boolean
---@field first_line integer
---@field last_line integer

---@class SubstituteMatchProps
---@field start_column integer
---@field end_column integer
---@field replacement string

---@class PendingSubstituteMatchProps
---@field matched_text string
---@field replacement string

---@class ReplacementCaseProps
---@field next_character? 'upper'|'lower'
---@field whole? 'upper'|'lower'

local M = {}
local SEARCH_HIGHLIGHT = 'Search'
local CURRENT_MATCH_HIGHLIGHT = 'IncSearch'
local SUBSTITUTE_HIGHLIGHT = 'Substitute'
local ALL_MATCHES_PRIORITY = 10
local CURRENT_MATCH_PRIORITY = 200
local MATCH_MARKER = '\1'
local MARK_MATCH_EXPRESSION =
  [[\=v:lua.require'utils.cmdline_preview'.mark_substitute_match()]]
local LINE_BREAK_SYMBOL = '↵'
local PREVIEW_CMDLINE_TYPES = { [':'] = true, ['/'] = true, ['?'] = true }
local PREVIEW_EVENTS = {
  'TextChanged',
  'TextChangedI',
  'TextChangedP',
  'CursorMoved',
  'CursorMovedI',
}
local namespace = vim.api.nvim_create_namespace 'cmdline-preview'

---@type CmdlinePreviewProps|nil
local active_preview = nil

---@type PendingSubstituteMatchProps[]
local pending_matches = {}

local current_replacement = ''

---@param line string
---@param delimiter string
---@return string
local function extract_search_pattern(line, delimiter)
  local index = 1

  while index <= #line do
    local character = line:sub(index, index)
    if character == '\\' then
      index = index + 2
    elseif character == delimiter then
      return line:sub(1, index - 1)
    else
      index = index + 1
    end
  end

  return line
end

---@param pattern string
---@return string
local function get_case_prefix(pattern)
  if not vim.o.ignorecase then return '' end
  local unescaped_pattern = pattern:gsub('\\.', '')
  if vim.o.smartcase and unescaped_pattern:find '%u' then return '' end
  return '\\c'
end

---@param buffer integer
---@param line_number integer
---@param column integer
---@return integer
local function get_exclusive_end_column(buffer, line_number, column)
  local text = vim.api.nvim_buf_get_lines(
    buffer,
    line_number - 1,
    line_number,
    false
  )[1] or ''
  local last_character = vim.fn.matchstr(text, '.', column - 1)
  return column - 1 + #last_character
end

---@param preview CmdlinePreviewProps
---@param pattern string
local function highlight_all_matches(preview, pattern)
  local success, match_id = pcall(
    vim.fn.matchadd,
    SEARCH_HIGHLIGHT,
    get_case_prefix(pattern) .. pattern,
    ALL_MATCHES_PRIORITY,
    -1,
    { window = preview.source_window }
  )
  if success and match_id > 0 then
    preview.match_ids[#preview.match_ids + 1] = match_id
  end
end

---@param preview CmdlinePreviewProps
---@param pattern string
local function highlight_current_match(preview, pattern)
  local direction = preview.cmdline_type == '?' and 'b' or ''
  local wrap = vim.o.wrapscan and 'w' or 'W'

  vim.api.nvim_win_call(preview.source_window, function()
    local found, start_position =
      pcall(vim.fn.searchpos, pattern, direction .. wrap)
    if not found or start_position[1] == 0 then return end

    local ended, end_position = pcall(vim.fn.searchpos, pattern, 'cenW')
    if not ended or end_position[1] == 0 then end_position = start_position end
    vim.api.nvim_win_set_cursor(0, { start_position[1], start_position[2] - 1 })

    local top_line, bottom_line = vim.fn.line 'w0', vim.fn.line 'w$'
    if start_position[1] < top_line or start_position[1] > bottom_line then
      vim.cmd 'normal! zz'
    end

    vim.api.nvim_buf_set_extmark(
      preview.source_buffer,
      namespace,
      start_position[1] - 1,
      start_position[2] - 1,
      {
        end_row = end_position[1] - 1,
        end_col = get_exclusive_end_column(
          preview.source_buffer,
          end_position[1],
          end_position[2]
        ),
        hl_group = CURRENT_MATCH_HIGHLIGHT,
        priority = CURRENT_MATCH_PRIORITY,
        strict = false,
      }
    )
  end)
end

---@param preview CmdlinePreviewProps
---@param line string
local function update_search(preview, line)
  local pattern = extract_search_pattern(line, preview.cmdline_type)
  if pattern == '' then return end

  highlight_all_matches(preview, pattern)
  highlight_current_match(preview, pattern)
end

---@param line string
---@return integer|nil
local function find_command_start(line)
  local index = 1

  while index <= #line do
    local character = line:sub(index, index)

    if character == "'" or character == '\\' then
      index = index + 2
    elseif character == '/' or character == '?' then
      index = index + 1
      while index <= #line and line:sub(index, index) ~= character do
        if line:sub(index, index) == '\\' then index = index + 1 end
        index = index + 1
      end
      index = index + 1
    elseif character:match '%a' then
      return index
    else
      index = index + 1
    end
  end

  return nil
end

---@param text string
---@param delimiter string
---@return string[]
local function split_by_delimiter(text, delimiter)
  local parts, current, index = {}, {}, 1

  while index <= #text do
    local character = text:sub(index, index)
    if character == '\\' and text:sub(index + 1, index + 1) == delimiter then
      current[#current + 1] = delimiter == '/' and '\\/' or delimiter
      index = index + 2
    elseif character == '\\' then
      current[#current + 1] = text:sub(index, index + 1)
      index = index + 2
    elseif character == delimiter then
      parts[#parts + 1] = table.concat(current)
      current = {}
      index = index + 1
    else
      current[#current + 1] = character
      index = index + 1
    end
  end

  parts[#parts + 1] = table.concat(current)
  return parts
end

---@param text string
---@param case ReplacementCaseProps
---@return string
local function apply_case(text, case)
  if case.whole == 'upper' then text = text:upper() end
  if case.whole == 'lower' then text = text:lower() end
  if case.next_character == 'upper' then
    text = text:sub(1, 1):upper() .. text:sub(2)
  elseif case.next_character == 'lower' then
    text = text:sub(1, 1):lower() .. text:sub(2)
  end

  case.next_character = nil
  return text
end

---@param replacement string
---@param submatches string[]
---@return string
local function expand_replacement(replacement, submatches)
  local result = {}
  ---@type ReplacementCaseProps
  local case = {}
  local index = 1
  local function append(text)
    if text == '' then return end
    result[#result + 1] = apply_case(text, case)
  end

  while index <= #replacement do
    local character = replacement:sub(index, index)
    local following = replacement:sub(index + 1, index + 1)
    if character == '&' then
      append(submatches[1])
      index = index + 1
    elseif character == '\\' and following:match '%d' then
      append(submatches[tonumber(following) + 1] or '')
      index = index + 2
    elseif character == '\\' and (following == 'r' or following == 'n') then
      result[#result + 1] = LINE_BREAK_SYMBOL
      index = index + 2
    elseif character == '\\' and following == 't' then
      append '\t'
      index = index + 2
    elseif character == '\\' and (following == 'u' or following == 'l') then
      case.next_character = following == 'u' and 'upper' or 'lower'
      index = index + 2
    elseif character == '\\' and (following == 'U' or following == 'L') then
      case.whole = following == 'U' and 'upper' or 'lower'
      index = index + 2
    elseif character == '\\' and (following == 'E' or following == 'e') then
      case.whole = nil
      index = index + 2
    elseif character == '\\' and following ~= '' then
      append(following)
      index = index + 2
    else
      append(character)
      index = index + 1
    end
  end

  return table.concat(result)
end

---@return string
local function evaluate_replacement()
  local submatches = {}

  for group = 0, 9 do
    submatches[#submatches + 1] = vim.fn.submatch(group)
  end

  if current_replacement:sub(1, 2) == '\\=' then
    local success, value = pcall(vim.fn.eval, current_replacement:sub(3))
    if not success then return '' end
    return (tostring(value):gsub('\n', LINE_BREAK_SYMBOL))
  end

  return expand_replacement(current_replacement, submatches)
end

---@return string
function M.mark_substitute_match()
  pending_matches[#pending_matches + 1] = {
    matched_text = vim.fn.submatch(0),
    replacement = evaluate_replacement(),
  }
  return MATCH_MARKER
end

---@param line string
---@param source_window integer
---@return SubstituteProps|nil
local function parse_substitute(line, source_window)
  ---@type vim.api.keyset.cmd_ret|nil
  local parsed = vim.api.nvim_win_call(source_window, function()
    local success, result = pcall(vim.api.nvim_parse_cmd, line, {})
    return success and result or nil
  end)
  if not parsed or parsed.cmd ~= 'substitute' then return nil end

  local command_start = find_command_start(line)
  if not command_start then return nil end

  local command_name = line:match('^%a+', command_start)
  if ('substitute'):sub(1, #command_name) ~= command_name then return nil end

  local arguments = line:sub(command_start + #command_name)
  local delimiter = arguments:sub(1, 1)
  if delimiter == '' or delimiter:match '[%w%s"|\\]' then return nil end

  local parts = split_by_delimiter(arguments:sub(2), delimiter)
  local pattern = parts[1] ~= '' and parts[1] or vim.fn.getreg '/'
  if pattern == '' then return nil end

  local flags = (parts[3] or ''):match '^%S*'
  if flags:find 'I' then
    pattern = '\\C' .. pattern
  elseif flags:find 'i' then
    pattern = '\\c' .. pattern
  elseif vim.o.ignorecase and vim.o.smartcase and pattern:find '%u' then
    pattern = '\\C' .. pattern
  elseif vim.o.ignorecase then
    pattern = '\\c' .. pattern
  end

  local cursor_line = vim.api.nvim_win_get_cursor(source_window)[1]
  local range = parsed.range or {}

  return {
    pattern = pattern,
    replacement = parts[2] or '',
    is_global = flags:find 'g' ~= nil,
    is_count_only = flags:find 'n' ~= nil,
    first_line = range[1] or cursor_line,
    last_line = range[2] or range[1] or cursor_line,
  }
end

---@param text string
---@param substitute SubstituteProps
---@return SubstituteMatchProps[]
local function collect_line_matches(text, substitute)
  if text:find(MATCH_MARKER, 1, true) then return {} end
  pending_matches = {}
  current_replacement = substitute.replacement

  local success, marked_text = pcall(
    vim.fn.substitute,
    text,
    substitute.pattern,
    MARK_MATCH_EXPRESSION,
    substitute.is_global and 'g' or ''
  )
  if not success then return {} end

  local matches, column, position, match_index = {}, 0, 1, 0
  while true do
    local marker = marked_text:find(MATCH_MARKER, position, true)
    if not marker then break end
    column = column + (marker - position)
    match_index = match_index + 1
    local pending_match = pending_matches[match_index]
    if not pending_match then break end
    matches[#matches + 1] = {
      start_column = column,
      end_column = column + #pending_match.matched_text,
      replacement = pending_match.replacement,
    }
    column = column + #pending_match.matched_text
    position = marker + 1
  end

  pending_matches = {}
  return matches
end

---@param preview CmdlinePreviewProps
local function enable_conceal(preview)
  if preview.saved_window_options then return end
  local window = preview.source_window

  preview.saved_window_options = {
    conceallevel = vim.wo[window].conceallevel,
    concealcursor = vim.wo[window].concealcursor,
  }
  vim.wo[window].conceallevel = 2
  vim.wo[window].concealcursor = 'nvic'
end

---@param preview CmdlinePreviewProps
local function restore_conceal(preview)
  local saved = preview.saved_window_options
  if not saved or not vim.api.nvim_win_is_valid(preview.source_window) then
    return
  end

  vim.wo[preview.source_window].conceallevel = saved.conceallevel
  vim.wo[preview.source_window].concealcursor = saved.concealcursor
  preview.saved_window_options = nil
end

---@param buffer integer
---@param line_index integer
---@param match SubstituteMatchProps
---@param substitute SubstituteProps
local function render_substitute_match(buffer, line_index, match, substitute)
  if substitute.is_count_only then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match.start_column,
      {
        end_col = match.end_column,
        hl_group = SUBSTITUTE_HIGHLIGHT,
      }
    )
    return
  end

  if match.end_column > match.start_column then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match.start_column,
      {
        end_col = match.end_column,
        conceal = '',
      }
    )
  end

  if match.replacement ~= '' then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match.start_column,
      {
        virt_text = { { match.replacement, SUBSTITUTE_HIGHLIGHT } },
        virt_text_pos = 'inline',
      }
    )
  end
end

---@param preview CmdlinePreviewProps
---@param line string
local function update_substitute(preview, line)
  local substitute = parse_substitute(line, preview.source_window)
  if not substitute then
    restore_conceal(preview)
    return
  end

  local window = preview.source_window
  local buffer = preview.source_buffer
  local first_line = math.max(substitute.first_line, vim.fn.line('w0', window))
  local last_line = math.min(substitute.last_line, vim.fn.line('w$', window))
  if first_line > last_line then return end

  local lines =
    vim.api.nvim_buf_get_lines(buffer, first_line - 1, last_line, false)
  local has_matches = false

  for offset, text in ipairs(lines) do
    for _, match in ipairs(collect_line_matches(text, substitute)) do
      has_matches = true
      render_substitute_match(
        buffer,
        first_line + offset - 2,
        match,
        substitute
      )
    end
  end

  if has_matches and not substitute.is_count_only then
    enable_conceal(preview)
  else
    restore_conceal(preview)
  end
end

---@param preview CmdlinePreviewProps
local function clear(preview)
  if vim.api.nvim_win_is_valid(preview.source_window) then
    for _, match_id in ipairs(preview.match_ids) do
      pcall(vim.fn.matchdelete, match_id, preview.source_window)
    end
    vim.api.nvim_win_call(
      preview.source_window,
      function() vim.fn.winrestview(preview.saved_view) end
    )
  end

  preview.match_ids = {}
  if vim.api.nvim_buf_is_valid(preview.source_buffer) then
    vim.api.nvim_buf_clear_namespace(preview.source_buffer, namespace, 0, -1)
  end
end

---@param preview CmdlinePreviewProps
---@param line string
local function update(preview, line)
  clear(preview)
  if not vim.api.nvim_win_is_valid(preview.source_window) then return end

  if preview.cmdline_type == ':' then
    update_substitute(preview, line)
  else
    update_search(preview, line)
  end
end

---@param cmdwin_buffer integer
---@param source_window integer
---@param cmdline_type string
function M.attach(cmdwin_buffer, source_window, cmdline_type)
  M.detach()
  if not PREVIEW_CMDLINE_TYPES[cmdline_type] then return end

  ---@type CmdlinePreviewProps
  local preview = {
    source_window = source_window,
    source_buffer = vim.api.nvim_win_get_buf(source_window),
    cmdline_type = cmdline_type,
    saved_view = vim.api.nvim_win_call(source_window, vim.fn.winsaveview),
    match_ids = {},
  }
  active_preview = preview

  vim.api.nvim_create_autocmd(PREVIEW_EVENTS, {
    buffer = cmdwin_buffer,
    callback = function()
      if active_preview ~= preview then return true end
      update(preview, vim.api.nvim_get_current_line())
    end,
  })
end

function M.detach()
  if not active_preview then return end
  clear(active_preview)
  restore_conceal(active_preview)
  active_preview = nil
end

return M
