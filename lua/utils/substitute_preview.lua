local M = {}
local MATCH_MARKER = '\1'
local MARK_MATCH_EXPRESSION =
  [[\=v:lua.require'utils.substitute_preview'.mark_match()]]
local PREVIEW_HIGHLIGHT = 'Substitute'
local LINE_BREAK_SYMBOL = '↵'
local namespace = vim.api.nvim_create_namespace 'substitute-preview'
local active_preview = nil
local pending_matches = {}
local current_replacement = ''

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
end

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

local function apply_case(text, case_props)
  if case_props.whole == 'upper' then text = text:upper() end
  if case_props.whole == 'lower' then text = text:lower() end
  if case_props.next_character == 'upper' then
    text = text:sub(1, 1):upper() .. text:sub(2)
  elseif case_props.next_character == 'lower' then
    text = text:sub(1, 1):lower() .. text:sub(2)
  end

  case_props.next_character = nil
  return text
end

local function expand_replacement(replacement, submatches)
  local result = {}
  local case_props = { next_character = nil, whole = nil }
  local index = 1
  local function append(text)
    if text == '' then return end
    result[#result + 1] = apply_case(text, case_props)
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
      case_props.next_character = following == 'u' and 'upper' or 'lower'
      index = index + 2
    elseif character == '\\' and (following == 'U' or following == 'L') then
      case_props.whole = following == 'U' and 'upper' or 'lower'
      index = index + 2
    elseif character == '\\' and (following == 'E' or following == 'e') then
      case_props.whole = nil
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

function M.mark_match()
  pending_matches[#pending_matches + 1] = {
    matched_text = vim.fn.submatch(0),
    replacement = evaluate_replacement(),
  }
  return MATCH_MARKER
end

local function parse_substitute(line, source_window)
  local parsed_success, parsed = vim.api.nvim_win_call(
    source_window,
    function() return pcall(vim.api.nvim_parse_cmd, line, {}) end
  )
  if not parsed_success or parsed.cmd ~= 'substitute' then return nil end

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

local function collect_line_matches(text, substitute_props)
  if text:find(MATCH_MARKER, 1, true) then return {} end
  pending_matches = {}
  current_replacement = substitute_props.replacement

  local success, marked_text = pcall(
    vim.fn.substitute,
    text,
    substitute_props.pattern,
    MARK_MATCH_EXPRESSION,
    substitute_props.is_global and 'g' or ''
  )
  if not success then return {} end

  local matches, column, position, match_index = {}, 0, 1, 0
  while true do
    local marker = marked_text:find(MATCH_MARKER, position, true)
    if not marker then break end
    column = column + (marker - position)
    match_index = match_index + 1
    local match_props = pending_matches[match_index]
    if not match_props then break end
    matches[#matches + 1] = {
      start_column = column,
      end_column = column + #match_props.matched_text,
      replacement = match_props.replacement,
    }
    column = column + #match_props.matched_text
    position = marker + 1
  end

  pending_matches = {}
  return matches
end

local function enable_conceal(preview_props)
  if preview_props.saved_window_options then return end
  local window = preview_props.source_window

  preview_props.saved_window_options = {
    conceallevel = vim.wo[window].conceallevel,
    concealcursor = vim.wo[window].concealcursor,
  }
  vim.wo[window].conceallevel = 2
  vim.wo[window].concealcursor = 'nvic'
end

local function restore_conceal(preview_props)
  local saved = preview_props.saved_window_options
  if
    not saved or not vim.api.nvim_win_is_valid(preview_props.source_window)
  then
    return
  end

  vim.wo[preview_props.source_window].conceallevel = saved.conceallevel
  vim.wo[preview_props.source_window].concealcursor = saved.concealcursor
  preview_props.saved_window_options = nil
end

local function render_match(buffer, line_index, match_props, substitute_props)
  if substitute_props.is_count_only then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match_props.start_column,
      {
        end_col = match_props.end_column,
        hl_group = PREVIEW_HIGHLIGHT,
      }
    )
    return
  end

  if match_props.end_column > match_props.start_column then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match_props.start_column,
      {
        end_col = match_props.end_column,
        conceal = '',
      }
    )
  end

  if match_props.replacement ~= '' then
    vim.api.nvim_buf_set_extmark(
      buffer,
      namespace,
      line_index,
      match_props.start_column,
      {
        virt_text = { { match_props.replacement, PREVIEW_HIGHLIGHT } },
        virt_text_pos = 'inline',
      }
    )
  end
end

local function clear_marks(preview_props)
  if vim.api.nvim_buf_is_valid(preview_props.source_buffer) then
    vim.api.nvim_buf_clear_namespace(
      preview_props.source_buffer,
      namespace,
      0,
      -1
    )
  end
end

local function update(preview_props, line)
  clear_marks(preview_props)
  if not vim.api.nvim_win_is_valid(preview_props.source_window) then return end

  local substitute_props = parse_substitute(line, preview_props.source_window)
  if not substitute_props then
    restore_conceal(preview_props)
    return
  end

  local window = preview_props.source_window
  local buffer = preview_props.source_buffer
  local first_line =
    math.max(substitute_props.first_line, vim.fn.line('w0', window))
  local last_line =
    math.min(substitute_props.last_line, vim.fn.line('w$', window))
  if first_line > last_line then return end

  local lines =
    vim.api.nvim_buf_get_lines(buffer, first_line - 1, last_line, false)
  local has_matches = false

  for offset, text in ipairs(lines) do
    for _, match_props in ipairs(collect_line_matches(text, substitute_props)) do
      has_matches = true
      render_match(
        buffer,
        first_line + offset - 2,
        match_props,
        substitute_props
      )
    end
  end

  if has_matches and not substitute_props.is_count_only then
    enable_conceal(preview_props)
  else
    restore_conceal(preview_props)
  end
end

function M.attach(cmdwin_buffer, source_window)
  M.detach()
  active_preview = {
    source_window = source_window,
    source_buffer = vim.api.nvim_win_get_buf(source_window),
    saved_window_options = nil,
  }
  local preview_props = active_preview

  vim.api.nvim_create_autocmd(
    {
      'TextChanged',
      'TextChangedI',
      'TextChangedP',
      'CursorMoved',
      'CursorMovedI',
    },
    {
      buffer = cmdwin_buffer,
      callback = function()
        if active_preview ~= preview_props then return true end
        update(preview_props, vim.api.nvim_get_current_line())
      end,
    }
  )
end

function M.detach()
  if not active_preview then return end
  clear_marks(active_preview)
  restore_conceal(active_preview)
  active_preview = nil
end

return M
