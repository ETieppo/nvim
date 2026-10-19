local M = {}
local ALL_MATCHES_HIGHLIGHT = 'Search'
local CURRENT_MATCH_HIGHLIGHT = 'IncSearch'
local ALL_MATCHES_PRIORITY = 10
local CURRENT_MATCH_PRIORITY = 200
local namespace = vim.api.nvim_create_namespace 'search-preview'
local active_preview = nil

local function extract_pattern(line, delimiter)
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

local function case_prefix(pattern)
  if not vim.o.ignorecase then return '' end
  local unescaped_pattern = pattern:gsub('\\.', '')
  if vim.o.smartcase and unescaped_pattern:find '%u' then return '' end
  return '\\c'
end

local function exclusive_end_column(buffer, line_number, column)
  local text = vim.api.nvim_buf_get_lines(
    buffer,
    line_number - 1,
    line_number,
    false
  )[1] or ''
  local last_character = vim.fn.matchstr(text, '.', column - 1)
  return column - 1 + #last_character
end

local function clear(preview_props)
  if vim.api.nvim_win_is_valid(preview_props.source_window) then
    for _, match_id in ipairs(preview_props.match_ids) do
      pcall(vim.fn.matchdelete, match_id, preview_props.source_window)
    end
    vim.api.nvim_win_call(
      preview_props.source_window,
      function() vim.fn.winrestview(preview_props.saved_view) end
    )
  end

  preview_props.match_ids = {}
  if vim.api.nvim_buf_is_valid(preview_props.source_buffer) then
    vim.api.nvim_buf_clear_namespace(
      preview_props.source_buffer,
      namespace,
      0,
      -1
    )
  end
end

local function highlight_all_matches(preview_props, pattern)
  local success, match_id = pcall(
    vim.fn.matchadd,
    ALL_MATCHES_HIGHLIGHT,
    case_prefix(pattern) .. pattern,
    ALL_MATCHES_PRIORITY,
    -1,
    { window = preview_props.source_window }
  )
  if success and match_id > 0 then
    preview_props.match_ids[#preview_props.match_ids + 1] = match_id
  end
end

local function highlight_current_match(preview_props, pattern)
  local direction = preview_props.search_type == '?' and 'b' or ''
  local wrap = vim.o.wrapscan and 'w' or 'W'

  vim.api.nvim_win_call(preview_props.source_window, function()
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
      preview_props.source_buffer,
      namespace,
      start_position[1] - 1,
      start_position[2] - 1,
      {
        end_row = end_position[1] - 1,
        end_col = exclusive_end_column(
          preview_props.source_buffer,
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

local function update(preview_props, line)
  clear(preview_props)
  if not vim.api.nvim_win_is_valid(preview_props.source_window) then return end

  local pattern = extract_pattern(line, preview_props.search_type)
  if pattern == '' then return end

  highlight_all_matches(preview_props, pattern)
  highlight_current_match(preview_props, pattern)
end

function M.attach(cmdwin_buffer, source_window, search_type)
  M.detach()
  active_preview = {
    source_window = source_window,
    source_buffer = vim.api.nvim_win_get_buf(source_window),
    search_type = search_type,
    saved_view = vim.api.nvim_win_call(source_window, vim.fn.winsaveview),
    match_ids = {},
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
  clear(active_preview)
  active_preview = nil
end

return M
