local async = require 'utils.async'
local library = require 'layout.music.library'
local music_config = require 'layout.music.config'
local soloist = require 'layout.music.soloist'
local web_api = require 'layout.music.web_api'
local HttpResponseDto = require('utils.dtos').HttpResponseDto
local SoloistCommandEnum = require('layout.music.enums').SoloistCommandEnum

local M = {}
local LIKED_ID = music_config.liked_playlist_id
local PLAYLIST_URI_PREFIX = 'spotify:playlist:'
local NOT_FOUND_STATUS = 404
local NOTIFY_OPTIONS = { title = 'Music' }
---@type string|nil
local device_id = nil

---@async
---@return string|nil
local function resolve_device_id()
  if device_id then return device_id end

  device_id = web_api.find_device_id(music_config.device_name)
  if device_id then return device_id end

  soloist.send(SoloistCommandEnum.activate)
  async.sleep(music_config.device_lookup_delay_ms)
  device_id = web_api.find_device_id(music_config.device_name)
  return device_id
end

---@param playlist_id string
---@param track_uri string
---@return PlaybackBodyProps
local function build_playback_body(playlist_id, track_uri)
  if playlist_id ~= LIKED_ID then
    return {
      context_uri = PLAYLIST_URI_PREFIX .. playlist_id,
      offset = { uri = track_uri },
    }
  end

  local liked_uris = library.find_playlist(LIKED_ID).track_uris
  local start_index = 1
  for index, uri in ipairs(liked_uris) do
    if uri == track_uri then
      start_index = index
      break
    end
  end
  return {
    uris = vim.list_slice(
      liked_uris,
      start_index,
      start_index + music_config.context_uris_limit - 1
    ),
  }
end

---@async
---@param body PlaybackBodyProps
---@return HttpResponseDto|nil
local function start_playback_on_device(body)
  local target_device_id = resolve_device_id()
  if not target_device_id then return nil end

  local response = web_api.start_playback(target_device_id, body)
  if response.status ~= NOT_FOUND_STATUS then return response end

  device_id = nil
  target_device_id = resolve_device_id()
  return target_device_id and web_api.start_playback(target_device_id, body)
end

---@async
---@param playlist_id string
---@param track TrackDto
function M.play_in_playlist(playlist_id, track)
  if not soloist.ensure_ready() then return end

  local response =
    start_playback_on_device(build_playback_body(playlist_id, track.uri))
  if not response or not HttpResponseDto.is_success(response) then
    vim.notify.error('Could not play ' .. track.name, NOTIFY_OPTIONS)
  end
end

---@async
---@param track TrackDto
function M.play_track(track)
  soloist.send(SoloistCommandEnum.play, { uri = track.uri })
end

---@async
---@param track TrackDto
function M.queue(track)
  if soloist.send(SoloistCommandEnum.add_to_queue, { uri = track.uri }) then
    vim.notify.info('Queued ' .. track.name, NOTIFY_OPTIONS)
  end
end

---@async
---@param track TrackDto
function M.like(track)
  if library.is_liked(track.uri) then
    vim.notify.info(track.name .. ' is already liked', NOTIFY_OPTIONS)
    return
  end
  if not web_api.save_to_library { track.uri } then
    vim.notify.error('Could not like ' .. track.name, NOTIFY_OPTIONS)
    return
  end

  library.add_track(LIKED_ID, track)
  library.save()
  vim.notify.success('Liked ' .. track.name, NOTIFY_OPTIONS)
end

---@async
---@param playlist MusicPlaylistProps
---@param track TrackDto
function M.add_to_playlist(playlist, track)
  if vim.list_contains(playlist.track_uris, track.uri) then
    vim.notify.info(
      track.name .. ' is already in ' .. playlist.name,
      NOTIFY_OPTIONS
    )
    return
  end
  if not web_api.add_to_playlist(playlist.id, { track.uri }) then
    vim.notify.error('Could not add to ' .. playlist.name, NOTIFY_OPTIONS)
    return
  end

  library.add_track(playlist.id, track)
  library.save()
  vim.notify.success(
    'Added ' .. track.name .. ' to ' .. playlist.name,
    NOTIFY_OPTIONS
  )
end

---@async
---@return MusicPlaylistProps|nil
local function resolve_trash_playlist()
  local trash =
    library.find_owned_playlist_by_name(music_config.trash_playlist_name)
  if trash then return trash end

  local created =
    web_api.create_private_playlist(music_config.trash_playlist_name)
  if not created then return nil end
  library.add_playlist(created)
  return library.find_playlist(created.id)
end

---@async
---@param playlist_id string
---@param track_uri string
---@return boolean
local function remove_from_source(playlist_id, track_uri)
  if playlist_id == LIKED_ID then
    return web_api.remove_from_library { track_uri }
  end
  return web_api.remove_from_playlist(playlist_id, { track_uri })
end

---@param playlist_id string
---@return boolean
function M.can_trash(playlist_id)
  local playlist = library.find_playlist(playlist_id)
  return playlist ~= nil and library.is_owned(playlist)
end

---@async
---@param playlist_id string
---@param track TrackDto
function M.trash(playlist_id, track)
  if not remove_from_source(playlist_id, track.uri) then
    vim.notify.error('Could not remove ' .. track.name, NOTIFY_OPTIONS)
    return
  end
  library.remove_track(playlist_id, track.uri)

  local source = library.find_playlist(playlist_id)
  local is_trash = source ~= nil
    and source.name == music_config.trash_playlist_name
  local trash = not is_trash and resolve_trash_playlist() or nil
  if trash and web_api.add_to_playlist(trash.id, { track.uri }) then
    library.add_track(trash.id, track)
  end
  library.save()

  local destination = is_trash and 'Removed ' or 'Moved to trash '
  vim.notify.info(destination .. track.name, NOTIFY_OPTIONS)
end

---@async
local function skip_to_previous()
  if soloist.send(SoloistCommandEnum.seek, { position_ms = 0 }) then
    soloist.send(SoloistCommandEnum.skip_prev)
  end
end

---@async
local function toggle_pause()
  soloist.send(
    soloist.is_playing() and SoloistCommandEnum.pause or SoloistCommandEnum.play
  )
end

---@async
local function toggle_shuffle()
  local is_enabled = not soloist.is_shuffling()
  if soloist.send(SoloistCommandEnum.set_shuffle, { enabled = is_enabled }) then
    vim.notify.info(
      'Shuffle ' .. (is_enabled and 'on' or 'off'),
      NOTIFY_OPTIONS
    )
  end
end

function M.next() async.run(soloist.send, SoloistCommandEnum.skip_next) end

function M.previous() async.run(skip_to_previous) end

function M.restart()
  async.run(soloist.send, SoloistCommandEnum.seek, { position_ms = 0 })
end

function M.toggle_pause() async.run(toggle_pause) end

function M.toggle_shuffle() async.run(toggle_shuffle) end

return M
