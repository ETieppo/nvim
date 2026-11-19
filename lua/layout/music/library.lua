local async = require 'utils.async'
local music_config = require 'layout.music.config'
local music_dtos = require 'layout.music.dtos'
local storage = require 'layout.music.storage'
local web_api = require 'layout.music.web_api'

---@class MusicPlaylistProps
---@field id string
---@field name string
---@field owner_id string|nil
---@field snapshot_id string|nil
---@field track_uris string[]

---@class MusicLibraryProps
---@field user_id string|nil
---@field synced_on string|nil
---@field liked_signature string|nil
---@field playlist_ids string[]
---@field playlists table<string, MusicPlaylistProps>
---@field tracks table<string, TrackDto>

local M = {}
local LIBRARY_PATH =
  vim.fs.joinpath(music_config.state_directory, 'library.json')
local SPOTIFY_PLAYER_LIKED_PATH = vim.fs.joinpath(
  music_config.spotify_player_cache_directory,
  'SavedTracks_cache.json'
)
local SPOTIFY_PLAYER_PLAYLISTS_PATH = vim.fs.joinpath(
  music_config.spotify_player_cache_directory,
  'Playlists_cache.json'
)
local LIKED_ID = music_config.liked_playlist_id
local SYNC_DATE_FORMAT = '%Y-%m-%d'
local NOTIFY_OPTIONS = { title = 'Music' }
local TrackDto = music_dtos.TrackDto
local PlaylistDto = music_dtos.PlaylistDto
---@type MusicLibraryProps|nil
local library = nil
local is_syncing = false

---@param tracks TrackDto[]
---@return string[]
local function collect_uris(tracks)
  local uris = {}
  for index, track in ipairs(tracks) do
    uris[index] = track.uri
  end
  return uris
end

---@param playlist PlaylistDto
---@param track_uris string[]
---@param snapshot_id string|nil
---@return MusicPlaylistProps
local function create_playlist(playlist, track_uris, snapshot_id)
  return {
    id = playlist.id,
    name = playlist.name,
    owner_id = playlist.owner_id,
    snapshot_id = snapshot_id,
    track_uris = track_uris,
  }
end

---@param tracks TrackDto[]
---@return MusicPlaylistProps
local function create_liked_playlist(tracks)
  return create_playlist({
    id = LIKED_ID,
    name = music_config.liked_playlist_name,
  }, collect_uris(tracks), nil)
end

---@return MusicLibraryProps
local function create_empty_library()
  return {
    user_id = nil,
    synced_on = nil,
    liked_signature = nil,
    playlist_ids = {},
    playlists = { [LIKED_ID] = create_liked_playlist {} },
    tracks = {},
  }
end

---@param target MusicLibraryProps
---@param tracks TrackDto[]
local function register_tracks(target, tracks)
  for _, track in ipairs(tracks) do
    target.tracks[track.uri] = track
  end
end

---@param target MusicLibraryProps
---@return boolean
local function import_spotify_player_liked(target)
  local records = storage.read_json(SPOTIFY_PLAYER_LIKED_PATH)
  if not records then return false end

  local tracks = {}
  for uri, record in pairs(records) do
    tracks[#tracks + 1] = TrackDto.from_spotify_player_cache(uri, record)
  end
  table.sort(tracks, function(left, right) return left.name < right.name end)
  register_tracks(target, tracks)
  target.playlists[LIKED_ID] = create_liked_playlist(tracks)
  return true
end

---@param target MusicLibraryProps
---@return boolean
local function import_spotify_player_playlists(target)
  local records = storage.read_json(SPOTIFY_PLAYER_PLAYLISTS_PATH)
  if not records then return false end

  for _, record in ipairs(records) do
    if record.Playlist and record.Playlist.id then
      local playlist = PlaylistDto.from_spotify_player_cache(record.Playlist)
      target.playlist_ids[#target.playlist_ids + 1] = playlist.id
      target.playlists[playlist.id] = create_playlist(playlist, {}, nil)
    end
  end
  return true
end

---@return MusicLibraryProps|nil
local function import_spotify_player_cache()
  local imported = create_empty_library()
  local has_liked = import_spotify_player_liked(imported)
  local has_playlists = import_spotify_player_playlists(imported)
  if not has_liked and not has_playlists then return nil end
  return imported
end

---@return MusicLibraryProps
function M.get()
  if library then return library end

  library = storage.read_json(LIBRARY_PATH) --[[@as MusicLibraryProps|nil]]
  if library then return library end

  library = import_spotify_player_cache() or create_empty_library()
  M.save()
  return library
end

function M.save() storage.write_json(LIBRARY_PATH, M.get(), false) end

---@return string|nil
function M.get_synced_on() return M.get().synced_on end

---@param playlist_id string
---@return MusicPlaylistProps|nil
function M.find_playlist(playlist_id) return M.get().playlists[playlist_id] end

---@return MusicPlaylistProps[]
function M.list_playlists()
  local current = M.get()
  local playlists = { current.playlists[LIKED_ID] }
  for _, playlist_id in ipairs(current.playlist_ids) do
    playlists[#playlists + 1] = current.playlists[playlist_id]
  end
  return playlists
end

---@param playlist MusicPlaylistProps
---@return boolean
function M.is_owned(playlist)
  local current = M.get()
  return playlist.id == LIKED_ID
    or (current.user_id ~= nil and playlist.owner_id == current.user_id)
end

---@return MusicPlaylistProps[]
function M.list_owned_playlists()
  return vim.tbl_filter(
    function(playlist) return playlist.id ~= LIKED_ID and M.is_owned(playlist) end,
    M.list_playlists()
  )
end

---@param name string
---@return MusicPlaylistProps|nil
function M.find_owned_playlist_by_name(name)
  for _, playlist in ipairs(M.list_owned_playlists()) do
    if playlist.name == name then return playlist end
  end
  return nil
end

---@param playlist_id string
---@return TrackDto[]
function M.list_tracks(playlist_id)
  local current = M.get()
  local playlist = current.playlists[playlist_id]
  local tracks = {}
  for _, uri in ipairs(playlist and playlist.track_uris or {}) do
    tracks[#tracks + 1] = current.tracks[uri]
  end
  return tracks
end

---@param track_uri string
---@return boolean
function M.is_liked(track_uri)
  return vim.list_contains(M.get().playlists[LIKED_ID].track_uris, track_uri)
end

---@param playlist PlaylistDto
function M.add_playlist(playlist)
  local current = M.get()
  if current.playlists[playlist.id] then return end
  current.playlist_ids[#current.playlist_ids + 1] = playlist.id
  current.playlists[playlist.id] =
    create_playlist(playlist, {}, playlist.snapshot_id)
end

---@param playlist_id string
---@param track TrackDto
function M.add_track(playlist_id, track)
  local current = M.get()
  local playlist = current.playlists[playlist_id]
  if not playlist or vim.list_contains(playlist.track_uris, track.uri) then
    return
  end

  current.tracks[track.uri] = track
  table.insert(playlist.track_uris, 1, track.uri)
end

---@param playlist_id string
---@param track_uri string
function M.remove_track(playlist_id, track_uri)
  local playlist = M.get().playlists[playlist_id]
  if not playlist then return end
  playlist.track_uris = vim.tbl_filter(
    function(uri) return uri ~= track_uri end,
    playlist.track_uris
  )
end

---@param target MusicLibraryProps
local function collect_unused_tracks(target)
  ---@type table<string, boolean>
  local used_uris = {}
  for _, playlist in pairs(target.playlists) do
    for _, uri in ipairs(playlist.track_uris) do
      used_uris[uri] = true
    end
  end
  for uri in pairs(target.tracks) do
    if not used_uris[uri] then target.tracks[uri] = nil end
  end
end

---@param signature LikedSignatureProps
---@return string
local function serialize_liked_signature(signature)
  return signature.total .. ':' .. (signature.first_uri or '')
end

---@async
---@param target MusicLibraryProps
---@return boolean
local function sync_liked(target)
  local signature = web_api.get_liked_signature()
  if not signature then return false end

  local serialized_signature = serialize_liked_signature(signature)
  if serialized_signature == target.liked_signature then return true end

  local tracks = web_api.get_liked_tracks()
  if not tracks then return false end

  register_tracks(target, tracks)
  target.playlists[LIKED_ID] = create_liked_playlist(tracks)
  target.liked_signature = serialized_signature
  return true
end

---@async
---@param target MusicLibraryProps
---@param playlist PlaylistDto
---@return boolean
local function sync_playlist(target, playlist)
  local stored = target.playlists[playlist.id]
  local stored_uris = stored and stored.track_uris or {}
  if stored and stored.snapshot_id == playlist.snapshot_id then
    target.playlists[playlist.id] =
      create_playlist(playlist, stored_uris, playlist.snapshot_id)
    return true
  end

  local tracks, response = web_api.get_playlist_tracks(playlist.id)
  if response.is_network_error then return false end
  if not tracks then
    target.playlists[playlist.id] = create_playlist(playlist, stored_uris, nil)
    return true
  end

  register_tracks(target, tracks)
  target.playlists[playlist.id] =
    create_playlist(playlist, collect_uris(tracks), playlist.snapshot_id)
  return true
end

---@async
---@param target MusicLibraryProps
---@return boolean
local function sync_playlists(target)
  local playlists = web_api.get_playlists()
  if not playlists then return false end

  local previous_playlists = target.playlists
  local is_reachable = true
  target.playlists = { [LIKED_ID] = previous_playlists[LIKED_ID] }
  target.playlist_ids = {}
  for _, playlist in ipairs(playlists) do
    target.playlists[playlist.id] = previous_playlists[playlist.id]
      or create_playlist(playlist, {}, nil)
    target.playlist_ids[#target.playlist_ids + 1] = playlist.id
    is_reachable = is_reachable and sync_playlist(target, playlist)
  end
  return is_reachable
end

---@async
---@param target MusicLibraryProps
---@return boolean
local function sync_into(target)
  target.user_id = web_api.get_current_user_id() or target.user_id
  local is_liked_synced = sync_liked(target)
  local are_playlists_synced = sync_playlists(target)
  return target.user_id ~= nil and is_liked_synced and are_playlists_synced
end

---@async
---@param is_forced boolean
function M.sync(is_forced)
  if is_syncing then return end
  is_syncing = true

  local target = vim.deepcopy(M.get())
  local is_synced = sync_into(target)
  is_syncing = false

  collect_unused_tracks(target)
  if is_synced then
    target.synced_on = os.date(SYNC_DATE_FORMAT) --[[@as string]]
  end
  library = target
  M.save()

  if is_synced then
    vim.notify.success('Library synced on ' .. target.synced_on, NOTIFY_OPTIONS)
  elseif is_forced then
    vim.notify.warn('Library partially synced, retry later', NOTIFY_OPTIONS)
  end
end

function M.sync_if_outdated()
  if is_syncing or M.get().synced_on == os.date(SYNC_DATE_FORMAT) then
    return
  end
  async.run(M.sync, false)
end

return M
