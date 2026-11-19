local async = require 'utils.async'
local credentials = require 'layout.music.credentials'
local http = require 'utils.http'
local music_config = require 'layout.music.config'
local storage = require 'utils.storage'
local uv_handle = require 'utils.uv_handle'
local HttpMethodEnum = require('utils.enums').HttpMethodEnum
local TokenDto = require('layout.music.dtos').TokenDto

local M = {}
local TOKEN_PATH = vim.fs.joinpath(music_config.state_directory, 'token.json')
local AUTHORIZE_URL = 'https://accounts.spotify.com/authorize'
local TOKEN_URL = 'https://accounts.spotify.com/api/token'
local NOTIFY_OPTIONS = { title = 'Music' }
local EXPIRY_MARGIN_SECONDS = 60
local VERIFIER_BYTES = 32
local STATE_BYTES = 16
local LISTEN_BACKLOG = 8
local REQUEST_TERMINATOR = '\r\n\r\n'
local REQUEST_TARGET_PATTERN = '^GET (%S+)'
local SUCCESS_PAGE = 'Spotify connected. You can close this tab.'
local CALLBACK_RESPONSE =
  'HTTP/1.1 %s\r\nContent-Type: text/plain\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s'
local REDIRECT_URI = ('http://%s:%d%s'):format(
  music_config.redirect.host,
  music_config.redirect.port,
  music_config.redirect.path
)
---@type TokenDto|nil
local cached_token = nil

---@param count integer
---@return string
local function random_bytes(count) return assert(vim.uv.random(count)) end

---@param bytes string
---@return string
local function encode_base64_url(bytes)
  local encoded = vim.base64.encode(bytes):gsub('+', '-'):gsub('/', '_')
  return (encoded:gsub('=+$', ''))
end

---@param hex string
---@return string
local function decode_hex(hex)
  return (
    hex:gsub('%x%x', function(pair) return string.char(tonumber(pair, 16)) end)
  )
end

---@param token TokenDto|nil
---@return boolean
local function is_usable(token)
  return token ~= nil and token.expires_at - EXPIRY_MARGIN_SECONDS > os.time()
end

---@param query string
---@param name string
---@return string|nil
local function read_query_parameter(query, name)
  local value = query:match('[?&]' .. name .. '=([^&]+)')
  return value and vim.uri.decode(value)
end

---@param client uv.uv_tcp_t
---@param is_accepted boolean
local function respond_to_callback(client, is_accepted)
  local body = is_accepted and SUCCESS_PAGE or ''
  local status = is_accepted and '200 OK' or '404 Not Found'
  client:write(
    CALLBACK_RESPONSE:format(status, #body, body),
    function() uv_handle.close(client) end
  )
end

---@async
---@param expected_state string
---@return string|nil code
local function await_authorization_code(expected_state)
  return async.await(function(resolve)
    local server = assert(vim.uv.new_tcp())
    local timer = assert(vim.uv.new_timer())

    local function finish(code)
      uv_handle.close(timer)
      uv_handle.close(server)
      resolve(code)
    end

    local is_bound, bind_error =
      server:bind(music_config.redirect.host, music_config.redirect.port)
    if not is_bound then
      vim.notify.error(
        'Login callback unavailable: ' .. tostring(bind_error),
        NOTIFY_OPTIONS
      )
      return finish(nil)
    end

    server:listen(LISTEN_BACKLOG, function(listen_error)
      if listen_error then return finish(nil) end
      local client = assert(vim.uv.new_tcp())
      server:accept(client)

      local request = ''
      client:read_start(function(read_error, chunk)
        if read_error or not chunk then return uv_handle.close(client) end
        request = request .. chunk
        if not request:find(REQUEST_TERMINATOR, 1, true) then return end

        client:read_stop()
        local target = request:match(REQUEST_TARGET_PATTERN) or ''
        local code = read_query_parameter(target, 'code')
        local is_accepted = code ~= nil
          and vim.startswith(target, music_config.redirect.path)
          and read_query_parameter(target, 'state') == expected_state
        respond_to_callback(client, is_accepted)
        if is_accepted then finish(code) end
      end)
    end)

    timer:start(music_config.login_timeout_ms, 0, function() finish(nil) end)
  end)
end

---@async
---@param form table<string, string>
---@param previous_refresh_token string|nil
---@return TokenDto|nil token
---@return HttpResponseDto response
local function request_token(form, previous_refresh_token)
  local response = http.request_async {
    method = HttpMethodEnum.post,
    url = TOKEN_URL,
    form_body = form,
  }
  local decoded = storage.decode_json(response.body)
  if not decoded then return nil, response end
  return TokenDto.from_api(decoded, previous_refresh_token), response
end

---@param client_id string
---@param code_challenge string
---@param state string
---@return string
local function build_authorize_url(client_id, code_challenge, state)
  return AUTHORIZE_URL
    .. '?'
    .. http.encode_query {
      response_type = 'code',
      client_id = client_id,
      redirect_uri = REDIRECT_URI,
      scope = table.concat(music_config.scopes, ' '),
      code_challenge_method = 'S256',
      code_challenge = code_challenge,
      state = state,
    }
end

---@async
---@param client_id string
---@return TokenDto|nil
local function log_in(client_id)
  local code_verifier = encode_base64_url(random_bytes(VERIFIER_BYTES))
  local code_challenge =
    encode_base64_url(decode_hex(vim.fn.sha256(code_verifier)))
  local state = encode_base64_url(random_bytes(STATE_BYTES))

  vim.ui.open(build_authorize_url(client_id, code_challenge, state))
  vim.notify.info('Authorize Spotify in your browser', NOTIFY_OPTIONS)

  local code = await_authorization_code(state)
  if not code then
    vim.notify.warn('Spotify login was not completed', NOTIFY_OPTIONS)
    return nil
  end

  return (
    request_token({
      grant_type = 'authorization_code',
      code = code,
      redirect_uri = REDIRECT_URI,
      client_id = client_id,
      code_verifier = code_verifier,
    }, nil)
  )
end

---@async
---@param client_id string
---@param refresh_token string|nil
---@return TokenDto|nil
local function refresh_or_log_in(client_id, refresh_token)
  if not refresh_token then return log_in(client_id) end

  local token, response = request_token({
    grant_type = 'refresh_token',
    refresh_token = refresh_token,
    client_id = client_id,
  }, refresh_token)
  if token or response.is_network_error then return token end
  return log_in(client_id)
end

---@async
---@return TokenDto|nil
local authorize = async.single_flight(function()
  cached_token = cached_token or storage.read_json(TOKEN_PATH) --[[@as TokenDto|nil]]
  if is_usable(cached_token) then return cached_token end

  local resolved_credentials = credentials.resolve()
  if not resolved_credentials then return nil end

  local token = refresh_or_log_in(
    resolved_credentials.client_id,
    cached_token and cached_token.refresh_token
  )
  if not token then return nil end

  cached_token = token
  storage.write_json(TOKEN_PATH, token, true)
  return token
end)

---@async
---@return string|nil
function M.get_access_token()
  if cached_token and is_usable(cached_token) then
    return cached_token.access_token
  end
  local token = authorize()
  return token and token.access_token
end

function M.invalidate()
  if cached_token then cached_token.expires_at = 0 end
end

---@async
function M.log_in_again()
  cached_token = nil
  storage.remove(TOKEN_PATH)
  if M.get_access_token() then
    vim.notify.success('Spotify connected', NOTIFY_OPTIONS)
  end
end

return M
