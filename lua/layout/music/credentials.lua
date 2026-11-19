local async = require 'utils.async'
local music_config = require 'layout.music.config'
local storage = require 'utils.storage'

---@class MusicCredentialsProps
---@field client_id string
---@field soloist_api_key string

local M = {}
local CREDENTIALS_PATH =
  vim.fs.joinpath(music_config.state_directory, 'credentials.json')
local CLIENT_ID_PROMPT = 'Spotify app client ID: '
local SOLOIST_API_KEY_PROMPT = 'Soloist API key: '
---@type MusicCredentialsProps|nil
local cached_credentials = nil

---@param value any
---@return boolean
local function is_filled(value)
  return type(value) == 'string' and vim.trim(value) ~= ''
end

---@async
---@param prompt string
---@return string|nil
local function ask(prompt)
  local answer = async.await(
    function(resolve) vim.ui.input({ prompt = prompt }, resolve) end
  )
  return is_filled(answer) and vim.trim(answer) or nil
end

---@async
---@return MusicCredentialsProps|nil
function M.resolve()
  if cached_credentials then return cached_credentials end

  local stored = storage.read_json(CREDENTIALS_PATH) or {}
  local is_complete = is_filled(stored.client_id)
    and is_filled(stored.soloist_api_key)
  local client_id = is_filled(stored.client_id) and stored.client_id
    or ask(CLIENT_ID_PROMPT)
  if not client_id then return nil end
  local soloist_api_key = is_filled(stored.soloist_api_key)
      and stored.soloist_api_key
    or ask(SOLOIST_API_KEY_PROMPT)
  if not soloist_api_key then return nil end

  cached_credentials =
    { client_id = client_id, soloist_api_key = soloist_api_key }
  if not is_complete then
    storage.write_json(CREDENTIALS_PATH, cached_credentials, true)
  end
  return cached_credentials
end

---@async
function M.replace()
  cached_credentials = nil
  storage.remove(CREDENTIALS_PATH)
  if M.resolve() then
    vim.notify.success('Credentials saved', music_config.notify_options)
  end
end

return M
