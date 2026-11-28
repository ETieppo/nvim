local async = require 'utils.async'
local credentials = require 'layout.music.credentials'
local music_config = require 'layout.music.def'
local music_enums = require 'layout.music.enums'
local storage = require 'utils.storage'
local websocket = require 'utils.websocket'

---@class SoloistStateProps
---@field connection WebSocketConnectionProps|nil
---@field is_logged_in boolean
---@field has_auth_state boolean
---@field has_warned_pairing boolean
---@field playing_uri string|nil
---@field status SoloistPlaybackStatusEnum|nil
---@field is_shuffling boolean

---@class SoloistDaemonProps
---@field exit_code integer|nil

---@class SoloistEndpointProps
---@field host string
---@field port integer

---@alias SoloistTrackListenerProps fun(previous_uri: string|nil, current_uri: string|nil)

local M = {}
local SoloistEventEnum = music_enums.SoloistEventEnum
local SoloistPlaybackStatusEnum = music_enums.SoloistPlaybackStatusEnum
local DATA_DIRECTORY = music_config.soloist_data_directory
local PORT_PATH = vim.fs.joinpath(DATA_DIRECTORY, 'ws.port')
local ADDRESS_PATH = vim.fs.joinpath(DATA_DIRECTORY, 'ws.addr')
local PID_PATH = vim.fs.joinpath(DATA_DIRECTORY, 'soloist.pid')
local SOLOIST_EXECUTABLE = 'soloist'
local MPRIS_ADAPTER_EXECUTABLE = 'soloist_mpris_adapter'
local LISTEN_ADDRESS = '127.0.0.1:0'
local DEFAULT_HOST = '127.0.0.1'
local HOST_PORT_PATTERN = '^(.-):(%d+)$'
local BUILD_EXPIRED_EXIT_CODE = 10
local NOTIFY_OPTIONS = music_config.notify_options
local COMMAND_MESSAGE_TYPE = 'command'
---@type SoloistStateProps
local state = {
  connection = nil,
  is_logged_in = false,
  has_auth_state = false,
  has_warned_pairing = false,
  playing_uri = nil,
  status = nil,
  is_shuffling = false,
}
---@type SoloistTrackListenerProps[]
local track_listeners = {}
---@type fun()|nil
local resolve_auth_state = nil

---@return SoloistEndpointProps|nil
local function read_endpoint()
  local port = tonumber(storage.read_first_line(PORT_PATH) or '')
  if not port then return nil end

  local address = storage.read_first_line(ADDRESS_PATH) or DEFAULT_HOST
  local host = address:match(HOST_PORT_PATTERN) or address
  return { host = host ~= '' and host or DEFAULT_HOST, port = port }
end

---@return integer|nil
local function find_running_pid()
  local pid = tonumber(storage.read_first_line(PID_PATH) or '')
  if pid and vim.uv.kill(pid, 0) == 0 then return pid end
  return nil
end

---@param uri string|nil
local function set_playing_uri(uri)
  if uri == state.playing_uri then return end
  local previous_uri = state.playing_uri
  state.playing_uri = uri
  for _, listener in ipairs(track_listeners) do
    listener(previous_uri, uri)
  end
end

---@param item table|nil
---@return string|nil
local function read_item_uri(item) return item and item.uri end

local function warn_pairing_once()
  if state.has_warned_pairing then return end
  state.has_warned_pairing = true
  vim.notify.warn(
    ('Select "%s" in a Spotify app once to pair it'):format(
      music_config.device_name
    ),
    NOTIFY_OPTIONS
  )
end

---@param event table
local function apply_auth_state(event)
  state.is_logged_in = event.logged_in == true
  state.has_auth_state = true
  if resolve_auth_state then resolve_auth_state() end
end

---@param event table
local function apply_track_change(event)
  set_playing_uri(read_item_uri(event.item))
end

---@param event table
local function apply_playback_change(event) state.status = event.status end

---@param event table
local function apply_options_change(event)
  state.is_shuffling = event.options ~= nil and event.options.shuffle == true
end

---@param event table
local function notify_error(event)
  vim.notify.error(tostring(event.message), NOTIFY_OPTIONS)
end

---@param event table
local function apply_playback_state(event)
  apply_playback_change(event)
  apply_options_change(event)
  apply_track_change(event)
end

---@type table<SoloistEventEnum, fun(event: table)>
local EVENT_HANDLERS = {
  [SoloistEventEnum.auth_state] = apply_auth_state,
  [SoloistEventEnum.playback_state] = apply_playback_state,
  [SoloistEventEnum.track_changed] = apply_track_change,
  [SoloistEventEnum.playback_changed] = apply_playback_change,
  [SoloistEventEnum.options_changed] = apply_options_change,
  [SoloistEventEnum.error] = notify_error,
}

---@param text string
local function handle_message(text)
  local event = storage.decode_json(text)
  if not event then return end
  local handler = EVENT_HANDLERS[event.type]
  if handler then handler(event) end
end

---@param reason string
local function handle_close(reason)
  state.connection = nil
  state.is_logged_in = false
  state.has_auth_state = false
  state.status = nil
  set_playing_uri(nil)
  if resolve_auth_state then resolve_auth_state() end
  vim.notify.debug('Soloist disconnected: ' .. reason, NOTIFY_OPTIONS)
end

---@async
---@param endpoint SoloistEndpointProps
---@return boolean
local function open_connection(endpoint)
  return async.await(function(resolve)
    resolve_auth_state = function()
      resolve_auth_state = nil
      resolve(state.connection ~= nil)
    end
    state.connection = websocket.connect(endpoint.host, endpoint.port, {
      on_open = function() end,
      on_text = handle_message,
      on_close = handle_close,
    })
  end) == true
end

---@param executable string
---@param args string[]
---@param on_exit fun(code: integer)
---@return boolean is_spawned
---@return string|nil error_message
local function spawn_detached(executable, args, on_exit)
  local handle, spawn_error =
    vim.uv.spawn(executable, { args = args, detached = true }, on_exit)
  if not handle then return false, tostring(spawn_error) end
  handle:unref()
  return true, nil
end

---@param api_key string
---@return SoloistDaemonProps|nil daemon
---@return string|nil error_message
local function spawn_daemon(api_key)
  ---@type SoloistDaemonProps
  local daemon = { exit_code = nil }
  local is_spawned, spawn_error = spawn_detached(SOLOIST_EXECUTABLE, {
    '--device-name',
    music_config.device_name,
    '--api-key',
    api_key,
    '--data-dir',
    DATA_DIRECTORY,
    '--ws',
    LISTEN_ADDRESS,
  }, function(code) daemon.exit_code = code end)
  if not is_spawned then return nil, spawn_error end
  return daemon, nil
end

---@async
---@param daemon SoloistDaemonProps
---@return SoloistEndpointProps|nil
local function await_endpoint(daemon)
  local elapsed = 0
  while elapsed < music_config.soloist_startup_timeout_ms do
    local endpoint = read_endpoint()
    if endpoint then return endpoint end
    if daemon.exit_code ~= nil then return nil end
    async.sleep(music_config.soloist_poll_interval_ms)
    elapsed = elapsed + music_config.soloist_poll_interval_ms
  end
  return nil
end

---@param daemon SoloistDaemonProps
local function notify_start_failure(daemon)
  if daemon.exit_code == BUILD_EXPIRED_EXIT_CODE then
    vim.notify.error(
      'Soloist build expired, install a newer one',
      NOTIFY_OPTIONS
    )
    return
  end
  vim.notify.error('Soloist did not start', NOTIFY_OPTIONS)
end

---@param running_pid integer
---@param has_endpoint boolean
local function notify_unreachable_daemon(running_pid, has_endpoint)
  local message = has_endpoint
      and 'Soloist (pid %d) is running but refused the connection'
    or 'Soloist (pid %d) runs without the WebSocket API, stop it so Neovim can manage it'
  vim.notify.warn(message:format(running_pid), NOTIFY_OPTIONS)
end

---@async
---@param has_endpoint boolean
---@return SoloistEndpointProps|nil
local function start_daemon(has_endpoint)
  local running_pid = find_running_pid()
  if running_pid then
    notify_unreachable_daemon(running_pid, has_endpoint)
    return nil
  end

  local resolved_credentials = credentials.resolve()
  if not resolved_credentials then return nil end

  storage.remove(PORT_PATH)
  local daemon, spawn_error = spawn_daemon(resolved_credentials.soloist_api_key)
  if not daemon then
    vim.notify.error(
      'Could not start Soloist: ' .. tostring(spawn_error) .. '\nRun :Deps i',
      NOTIFY_OPTIONS
    )
    return nil
  end

  local endpoint = await_endpoint(daemon)
  if not endpoint then notify_start_failure(daemon) end
  return endpoint
end

local function start_mpris_adapter()
  if vim.fn.executable(MPRIS_ADAPTER_EXECUTABLE) ~= 1 then return end
  spawn_detached(
    MPRIS_ADAPTER_EXECUTABLE,
    { '--data-dir', DATA_DIRECTORY },
    function(_) end
  )
end

---@async
---@param should_start boolean
---@return boolean
local function connect(should_start)
  local endpoint = read_endpoint()
  if endpoint and open_connection(endpoint) then return true end
  if not should_start then return false end

  endpoint = start_daemon(endpoint ~= nil)
  return endpoint ~= nil and open_connection(endpoint)
end

---@async
---@param should_start boolean
---@return boolean
local establish_connection = async.single_flight(function(should_start)
  local is_connected = connect(should_start)
  if is_connected then start_mpris_adapter() end
  return is_connected
end)

---@async
---@param should_start boolean
---@return boolean
local function ensure_connection(should_start)
  if state.connection and websocket.is_open(state.connection) then
    return true
  end
  return establish_connection(should_start) == true
end

---@async
---@return boolean
function M.ensure_ready()
  if not ensure_connection(true) then return false end
  if not state.is_logged_in then warn_pairing_once() end
  return state.is_logged_in
end

---@async
function M.connect_if_running() ensure_connection(false) end

---@async
---@param command SoloistCommandEnum
---@param fields? table
---@return boolean
function M.send(command, fields)
  if not M.ensure_ready() then return false end
  local message = vim.tbl_extend(
    'force',
    { type = COMMAND_MESSAGE_TYPE, command = command },
    fields or {}
  )
  return websocket.send_text(state.connection, vim.json.encode(message))
end

---@param listener SoloistTrackListenerProps
function M.on_track_change(listener)
  track_listeners[#track_listeners + 1] = listener
end

---@return string|nil
function M.get_playing_uri() return state.playing_uri end

---@return boolean
function M.is_playing()
  return state.status == SoloistPlaybackStatusEnum.playing
    or state.status == SoloistPlaybackStatusEnum.buffering
end

---@return boolean
function M.is_shuffling() return state.is_shuffling end

return M
