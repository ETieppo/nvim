local async = require 'utils.async'
local auth = require 'layout.music.auth'
local http = require 'utils.http'
local music_config = require 'layout.music.config'
local storage = require 'utils.storage'
local HttpMethodEnum = require('utils.enums').HttpMethodEnum
local HttpResponseDto = require('utils.dtos').HttpResponseDto
local music_dtos = require 'layout.music.dtos'

---@class WebApiRequestOptionsProps
---@field query? table<string, string|integer>
---@field json_body? table

---@class LikedSignatureProps
---@field total integer
---@field first_uri string|nil

---@class PlaylistEntryProps
---@field track TrackDto
---@field added_at string
---@field position integer

---@class PlaybackBodyProps
---@field context_uri? string
---@field uris? string[]
---@field offset? { uri: string }

local M = {}
local API_BASE_URL = 'https://api.spotify.com/v1/'
local UNAUTHORIZED_STATUS = 401
local RATE_LIMITED_STATUS = 429
local DEFAULT_RETRY_AFTER_SECONDS = 1
local MILLISECONDS_PER_SECOND = 1000
local SECONDS_PER_HOUR = 3600
local QUOTA_NOTIFY_OPTIONS = vim.tbl_extend(
  'force',
  music_config.notify_options,
  { id = 'music-quota-exceeded' }
)
local PLAYLIST_ITEMS_FIELDS =
  'items(added_at,is_local,item(uri,name,is_local,artists(name),album(name)))'
local UNAUTHENTICATED_RESPONSE =
  HttpResponseDto.failure(false, 'Spotify is not connected')
local TrackDto = music_dtos.TrackDto
local PlaylistDto = music_dtos.PlaylistDto

---@param retry_after_seconds integer
local function notify_quota_exceeded(retry_after_seconds)
  vim.notify.warn(
    ('Spotify quota exceeded, it resets in about %dh'):format(
      math.ceil(retry_after_seconds / SECONDS_PER_HOUR)
    ),
    QUOTA_NOTIFY_OPTIONS
  )
end

---@async
---@param method HttpMethodEnum
---@param endpoint string
---@param options? WebApiRequestOptionsProps
---@return table|nil data
---@return HttpResponseDto response
function M.request(method, endpoint, options)
  local request_options = options or {}
  local response = UNAUTHENTICATED_RESPONSE
  local has_refreshed_token = false

  for _ = 0, music_config.rate_limit_retries do
    local access_token = auth.get_access_token()
    if not access_token then return nil, UNAUTHENTICATED_RESPONSE end

    response = http.request_async {
      method = method,
      url = API_BASE_URL .. endpoint,
      query = request_options.query,
      json_body = request_options.json_body,
      headers = { Authorization = 'Bearer ' .. access_token },
    }

    if response.status == UNAUTHORIZED_STATUS and not has_refreshed_token then
      has_refreshed_token = true
      auth.invalidate()
    elseif response.status == RATE_LIMITED_STATUS then
      local retry_after_seconds = response.retry_after_seconds
        or DEFAULT_RETRY_AFTER_SECONDS
      if retry_after_seconds > music_config.rate_limit_max_wait_seconds then
        notify_quota_exceeded(retry_after_seconds)
        break
      end
      async.sleep(retry_after_seconds * MILLISECONDS_PER_SECOND)
    else
      break
    end
  end

  if not HttpResponseDto.is_success(response) then return nil, response end
  return storage.decode_json(response.body) or {}, response
end

---@async
---@generic T
---@param endpoint string
---@param query table<string, string|integer>
---@param map_item fun(item: table): T|nil
---@return T[]|nil items
---@return HttpResponseDto response
local function collect_pages(endpoint, query, map_item)
  local items = {}
  local page_query = vim.tbl_extend('force', query, {
    limit = music_config.page_limit,
    offset = 0,
  })

  while true do
    local data, response =
      M.request(HttpMethodEnum.get, endpoint, { query = page_query })
    if not data then return nil, response end

    local page_items = data.items or {}
    for _, item in ipairs(page_items) do
      items[#items + 1] = map_item(item)
    end
    if #page_items < music_config.page_limit then return items, response end
    page_query.offset = page_query.offset + music_config.page_limit
  end
end

---@param entries PlaylistEntryProps[]
---@return TrackDto[]
local function sort_newest_first(entries)
  table.sort(entries, function(left, right)
    if left.added_at ~= right.added_at then
      return left.added_at > right.added_at
    end
    return left.position > right.position
  end)

  local tracks = {}
  for index, entry in ipairs(entries) do
    tracks[index] = entry.track
  end
  return tracks
end

---@param saved_item table
---@return TrackDto|nil
local function map_saved_item(saved_item)
  return TrackDto.from_api(saved_item.track or saved_item.item)
end

---@async
---@return string|nil
function M.get_current_user_id()
  local data = M.request(HttpMethodEnum.get, 'me')
  return data and data.id
end

---@async
---@return PlaylistDto[]|nil playlists
---@return HttpResponseDto response
function M.get_playlists()
  return collect_pages('me/playlists', {}, PlaylistDto.from_api)
end

---@async
---@param playlist_id string
---@return TrackDto[]|nil tracks
---@return HttpResponseDto response
function M.get_playlist_tracks(playlist_id)
  local position = 0
  local entries, response = collect_pages(
    'playlists/' .. playlist_id .. '/items',
    { fields = PLAYLIST_ITEMS_FIELDS },
    function(item)
      local track = TrackDto.from_playlist_item(item)
      if not track then return nil end
      position = position + 1
      return {
        track = track,
        added_at = item.added_at or '',
        position = position,
      }
    end
  )
  if not entries then return nil, response end
  return sort_newest_first(entries), response
end

---@async
---@return TrackDto[]|nil tracks
---@return HttpResponseDto response
function M.get_liked_tracks()
  return collect_pages('me/tracks', {}, map_saved_item)
end

---@async
---@return LikedSignatureProps|nil
function M.get_liked_signature()
  local data =
    M.request(HttpMethodEnum.get, 'me/tracks', { query = { limit = 1 } })
  if not data then return nil end

  local first_track = data.items
    and data.items[1]
    and map_saved_item(data.items[1])
  return {
    total = tonumber(data.total) or 0,
    first_uri = first_track and first_track.uri,
  }
end

---@async
---@param query string
---@return TrackDto[]|nil
function M.search_tracks(query)
  local data = M.request(HttpMethodEnum.get, 'search', {
    query = {
      q = query,
      type = 'track',
      limit = music_config.search_limit,
    },
  })
  if not data then return nil end

  local tracks = {}
  for _, track in ipairs(data.tracks and data.tracks.items or {}) do
    tracks[#tracks + 1] = TrackDto.from_api(track)
  end
  return tracks
end

---@async
---@param device_name string
---@return string|nil
function M.find_device_id(device_name)
  local data = M.request(HttpMethodEnum.get, 'me/player/devices')
  for _, device in ipairs(data and data.devices or {}) do
    if device.name == device_name then return device.id end
  end
  return nil
end

---@async
---@param device_id string
---@param body PlaybackBodyProps
---@return HttpResponseDto
function M.start_playback(device_id, body)
  local _, response = M.request(HttpMethodEnum.put, 'me/player/play', {
    query = { device_id = device_id },
    json_body = body,
  })
  return response
end

---@async
---@param playlist_id string
---@param uris string[]
---@return boolean
function M.add_to_playlist(playlist_id, uris)
  return M.request(
    HttpMethodEnum.post,
    'playlists/' .. playlist_id .. '/items',
    { json_body = { uris = uris } }
  ) ~= nil
end

---@async
---@param playlist_id string
---@param uris string[]
---@return boolean
function M.remove_from_playlist(playlist_id, uris)
  local items = {}
  for index, uri in ipairs(uris) do
    items[index] = { uri = uri }
  end
  return M.request(
    HttpMethodEnum.delete,
    'playlists/' .. playlist_id .. '/items',
    { json_body = { items = items } }
  ) ~= nil
end

---@async
---@param name string
---@return PlaylistDto|nil
function M.create_private_playlist(name)
  local data = M.request(HttpMethodEnum.post, 'me/playlists', {
    json_body = { name = name, public = false },
  })
  return data and data.id and PlaylistDto.from_api(data) or nil
end

---@async
---@param method HttpMethodEnum
---@param uris string[]
---@return boolean
local function change_library(method, uris)
  return M.request(method, 'me/library', {
    query = { uris = table.concat(uris, ',') },
    json_body = {},
  }) ~= nil
end

---@async
---@param uris string[]
---@return boolean
function M.save_to_library(uris)
  return change_library(HttpMethodEnum.put, uris)
end

---@async
---@param uris string[]
---@return boolean
function M.remove_from_library(uris)
  return change_library(HttpMethodEnum.delete, uris)
end

return M
