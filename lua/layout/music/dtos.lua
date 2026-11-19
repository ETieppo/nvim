---@class TrackDto
---@field uri string
---@field name string
---@field artists string
---@field album string

---@class PlaylistDto
---@field id string
---@field name string
---@field owner_id string|nil
---@field snapshot_id string|nil

---@class TokenDto
---@field access_token string
---@field refresh_token string|nil
---@field expires_at integer

local M = {}
local TRACK_URI_PREFIX = 'spotify:track:'
local ARTIST_SEPARATOR = ', '

M.TrackDto = {}
M.PlaylistDto = {}
M.TokenDto = {}

---@param artists { name: string }[]|nil
---@return string
local function join_artist_names(artists)
  local names = {}
  for index, artist in ipairs(artists or {}) do
    names[index] = artist.name
  end
  return table.concat(names, ARTIST_SEPARATOR)
end

---@param uri string
---@param record table
---@return TrackDto
local function create_track(uri, record)
  return {
    uri = uri,
    name = record.name or '',
    artists = join_artist_names(record.artists),
    album = record.album and record.album.name or '',
  }
end

---@param track table|nil
---@return TrackDto|nil
function M.TrackDto.from_api(track)
  if not track or track.is_local or type(track.uri) ~= 'string' then
    return nil
  end
  if not vim.startswith(track.uri, TRACK_URI_PREFIX) then return nil end
  return create_track(track.uri, track)
end

---@param playlist_item table
---@return TrackDto|nil
function M.TrackDto.from_playlist_item(playlist_item)
  if playlist_item.is_local then return nil end
  return M.TrackDto.from_api(playlist_item.item or playlist_item.track)
end

---@param uri string
---@param record table
---@return TrackDto
function M.TrackDto.from_spotify_player_cache(uri, record)
  return create_track(uri, record)
end

---@param playlist table
---@return PlaylistDto
function M.PlaylistDto.from_api(playlist)
  return {
    id = playlist.id,
    name = playlist.name or '',
    owner_id = playlist.owner and playlist.owner.id,
    snapshot_id = playlist.snapshot_id,
  }
end

---@param record table
---@return PlaylistDto
function M.PlaylistDto.from_spotify_player_cache(record)
  return {
    id = record.id,
    name = record.name or '',
    owner_id = record.owner and record.owner[2],
    snapshot_id = nil,
  }
end

---@param response table
---@param previous_refresh_token string|nil
---@return TokenDto|nil
function M.TokenDto.from_api(response, previous_refresh_token)
  if type(response.access_token) ~= 'string' then return nil end
  return {
    access_token = response.access_token,
    refresh_token = response.refresh_token or previous_refresh_token,
    expires_at = os.time() + (tonumber(response.expires_in) or 0),
  }
end

return M
