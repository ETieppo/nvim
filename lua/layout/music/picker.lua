local async = require 'utils.async'
local library = require 'layout.music.library'
local music_config = require 'layout.music.def'
local player = require 'layout.music.player'
local soloist = require 'layout.music.soloist'
local telescope_picker = require 'buffer.telescope.picker'
local uv_handle = require 'utils.uv_handle'
local web_api = require 'layout.music.web_api'

---@class MusicTrackEntryValueProps
---@field track TrackDto
---@field playlist_id string|nil
---@field label string
---@field separator_start integer|nil
---@field detail string|nil

---@class MusicTrackEntryProps
---@field value MusicTrackEntryValueProps
---@field ordinal string
---@field display fun(entry: MusicTrackEntryProps): string, table

---@class MusicTrackPickerOptionsProps
---@field sorter? table
---@field on_attach? fun(prompt_bufnr: integer, picker: table)

local M = {}
local PLAYING_HIGHLIGHT = 'MusicPlaying'
local SEPARATOR_HIGHLIGHT = 'MusicSeparator'
local DETAIL_HIGHLIGHT = 'Comment'
local ARTIST_SEPARATOR = ' • '
local DETAIL_SEPARATOR = '  '
local PLAYLIST_NAMES_SEPARATOR = ', '
local NOTIFY_OPTIONS = music_config.notify_options
---@type table|nil
local active_picker = nil
local is_listening_track_changes = false

---@param entry MusicTrackEntryProps
---@return string display
---@return table highlights
local function display_track(entry)
  local value = entry.value
  local text = value.label
  local highlights = {}

  if value.detail then
    local detail_start = #text + #DETAIL_SEPARATOR
    text = text .. DETAIL_SEPARATOR .. value.detail
    highlights[1] = { { detail_start, #text }, DETAIL_HIGHLIGHT }
  end
  if value.track.uri == soloist.get_playing_uri() then
    highlights = { { { 0, #text }, PLAYING_HIGHLIGHT } }
  end
  if value.separator_start then
    highlights[#highlights + 1] = {
      { value.separator_start, value.separator_start + #ARTIST_SEPARATOR },
      SEPARATOR_HIGHLIGHT,
    }
  end
  return text, highlights
end

---@param track TrackDto
---@param playlist_id string|nil
---@param detail string|nil
---@return MusicTrackEntryProps
local function create_track_entry(track, playlist_id, detail)
  local has_artists = track.artists ~= ''
  local label = has_artists and track.name .. ARTIST_SEPARATOR .. track.artists
    or track.name
  return {
    value = {
      track = track,
      playlist_id = playlist_id,
      label = label,
      separator_start = has_artists and #track.name or nil,
      detail = detail,
    },
    ordinal = detail and label .. ' ' .. detail or label,
    display = display_track,
  }
end

---@param entries table[]
---@return table
local function create_static_finder(entries)
  return require('telescope.finders').new_table {
    results = entries,
    entry_maker = function(entry) return entry end,
  }
end

---@param previous_uri string|nil
---@param current_uri string|nil
local function repaint_track_rows(previous_uri, current_uri)
  local picker = active_picker
  if
    not picker
    or not picker.manager
    or not vim.api.nvim_buf_is_valid(picker.results_bufnr)
  then
    return
  end

  for row = 0, vim.api.nvim_buf_line_count(picker.results_bufnr) - 1 do
    local index = picker:get_index(row)
    local entry = picker.manager:get_entry(index)
    local track = entry and entry.value and entry.value.track
    if track and (track.uri == previous_uri or track.uri == current_uri) then
      picker:entry_adder(index, entry, nil, false)
      if row == picker:get_selection_row() then picker:set_selection(row) end
    end
  end
end

local function listen_track_changes()
  if is_listening_track_changes then return end
  is_listening_track_changes = true
  soloist.on_track_change(repaint_track_rows)
end

---@param prompt_bufnr integer
---@return MusicTrackEntryValueProps|nil
local function get_selected_value(prompt_bufnr)
  local picker =
    require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local entry = picker and picker:get_selection()
  return entry and entry.value
end

---@param playlist MusicPlaylistProps
---@return string
local function format_playlist(playlist) return playlist.name end

---@param playlist MusicPlaylistProps
---@return string display
---@return table highlights
local function display_playlist(playlist)
  local count = tostring(#playlist.track_uris)
  local count_start = #playlist.name + #DETAIL_SEPARATOR
  return playlist.name .. DETAIL_SEPARATOR .. count,
    { { { count_start, count_start + #count }, DETAIL_HIGHLIGHT } }
end

---@param title string
---@param playlists MusicPlaylistProps[]
---@param on_pick fun(playlist: MusicPlaylistProps)
local function pick_playlist(title, playlists, on_pick)
  async.run(function()
    local playlist = telescope_picker.find {
      prompt = title,
      items = playlists,
      should_keep_order = true,
      format = format_playlist,
      display = display_playlist,
    }
    if playlist then on_pick(playlist) end
  end)
end

---@param value MusicTrackEntryValueProps
local function play(value)
  if value.playlist_id then
    async.run(player.play_in_playlist, value.playlist_id, value.track)
  else
    async.run(player.play_track, value.track)
  end
end

---@param prompt_bufnr integer
local function trash_selection(prompt_bufnr)
  local value = get_selected_value(prompt_bufnr)
  if not value or not value.playlist_id then return end
  if not player.can_trash(value.playlist_id) then
    vim.notify.warn('Only your own playlists can be edited', NOTIFY_OPTIONS)
    return
  end

  require('telescope.actions.state')
    .get_current_picker(prompt_bufnr)
    :delete_selection(function() return true end)
  async.run(player.trash, value.playlist_id, value.track)
end

---@param prompt_bufnr integer
local function add_selection_to_playlist(prompt_bufnr)
  local value = get_selected_value(prompt_bufnr)
  if not value then return end

  require('telescope.actions').close(prompt_bufnr)
  vim.schedule(function()
    pick_playlist(
      'Add ' .. value.track.name .. ' to',
      library.list_owned_playlists(),
      function(playlist)
        async.run(player.add_to_playlist, playlist, value.track)
      end
    )
  end)
end

---@param action async fun(track: TrackDto)
---@return fun(prompt_bufnr: integer)
local function run_on_selection(action)
  return function(prompt_bufnr)
    local value = get_selected_value(prompt_bufnr)
    if value then async.run(action, value.track) end
  end
end

---@param prompt_bufnr integer
---@param map fun(mode: string, key: string, action: function, opts?: table)
local function attach_track_actions(prompt_bufnr, map)
  local actions = require 'telescope.actions'
  actions.select_default:replace(function()
    local value = get_selected_value(prompt_bufnr)
    if not value then return end
    actions.close(prompt_bufnr)
    play(value)
  end)

  map('n', 'dd', trash_selection, { desc = 'Move track to trash' })
  map('n', 'q', run_on_selection(player.queue), { desc = 'Queue track' })
  map('n', 'l', run_on_selection(player.like), { desc = 'Like track' })
  map('n', 'p', add_selection_to_playlist, { desc = 'Add track to playlist' })
end

---@param title string
---@param entries MusicTrackEntryProps[]
---@param options MusicTrackPickerOptionsProps
local function open_track_picker(title, entries, options)
  listen_track_changes()
  async.run(soloist.connect_if_running)

  local picker
  picker = require('telescope.pickers').new({}, {
    prompt_title = title,
    finder = create_static_finder(entries),
    sorter = options.sorter
      or require('telescope.config').values.generic_sorter {},
    attach_mappings = function(prompt_bufnr, map)
      attach_track_actions(prompt_bufnr, map)
      telescope_picker.on_prompt_close(prompt_bufnr, function()
        if active_picker == picker then active_picker = nil end
      end)
      if options.on_attach then options.on_attach(prompt_bufnr, picker) end
      return true
    end,
  })
  active_picker = picker
  picker:find()
end

---@param playlist MusicPlaylistProps
local function open_playlist_tracks(playlist)
  local entries = {}
  for index, track in ipairs(library.list_tracks(playlist.id)) do
    entries[index] = create_track_entry(track, playlist.id, nil)
  end
  open_track_picker(playlist.name, entries, {})
end

---@param picker table
---@return string
local function read_prompt(picker)
  local line = vim.api.nvim_buf_get_lines(picker.prompt_bufnr, 0, 1, false)[1]
    or ''
  return vim.trim(line:sub(#picker.prompt_prefix + 1))
end

---@param prompt_bufnr integer
---@param picker table
local function attach_catalog_search(prompt_bufnr, picker)
  local timer = assert(vim.uv.new_timer())
  local latest_query = ''

  local function search()
    if not vim.api.nvim_buf_is_valid(prompt_bufnr) then return end
    local query = read_prompt(picker)
    if query == '' or query == latest_query then return end
    latest_query = query

    async.run(function()
      local tracks = web_api.search_tracks(query)
      if not tracks then
        vim.notify.warn('Spotify search failed', NOTIFY_OPTIONS)
        return
      end
      if
        query ~= latest_query
        or not vim.api.nvim_buf_is_valid(prompt_bufnr)
      then
        return
      end

      local entries = {}
      for index, track in ipairs(tracks) do
        entries[index] = create_track_entry(track, nil, track.album)
      end
      picker:refresh(create_static_finder(entries), { reset_prompt = false })
    end)
  end

  vim.api.nvim_buf_attach(prompt_bufnr, false, {
    on_lines = function()
      timer:stop()
      timer:start(music_config.search_debounce_ms, 0, vim.schedule_wrap(search))
    end,
  })
  telescope_picker.on_prompt_close(
    prompt_bufnr,
    function() uv_handle.close(timer) end
  )
end

function M.open_library()
  library.sync_if_outdated()
  pick_playlist('Music Library', library.list_playlists(), open_playlist_tracks)
end

function M.open_search()
  library.sync_if_outdated()
  ---@type TrackDto[]
  local unique_tracks = {}
  ---@type table<string, string>
  local first_playlist_ids = {}
  ---@type table<string, string[]>
  local playlist_names = {}
  for _, playlist in ipairs(library.list_playlists()) do
    for _, track in ipairs(library.list_tracks(playlist.id)) do
      if not first_playlist_ids[track.uri] then
        unique_tracks[#unique_tracks + 1] = track
        first_playlist_ids[track.uri] = playlist.id
        playlist_names[track.uri] = {}
      end
      table.insert(playlist_names[track.uri], playlist.name)
    end
  end

  local entries = {}
  for index, track in ipairs(unique_tracks) do
    entries[index] = create_track_entry(
      track,
      first_playlist_ids[track.uri],
      table.concat(playlist_names[track.uri], PLAYLIST_NAMES_SEPARATOR)
    )
  end
  open_track_picker('Search Music', entries, {})
end

function M.open_catalog()
  open_track_picker('Search Spotify', {}, {
    sorter = require('telescope.sorters').highlighter_only {},
    on_attach = attach_catalog_search,
  })
end

return M
