---@class MusicRedirectProps
---@field host string
---@field port integer
---@field path string

---@class MusicConfigProps
---@field state_directory string
---@field soloist_data_directory string
---@field spotify_player_cache_directory string
---@field device_name string
---@field redirect MusicRedirectProps
---@field scopes string[]
---@field liked_playlist_id string
---@field liked_playlist_name string
---@field trash_playlist_name string
---@field page_limit integer
---@field search_limit integer
---@field context_uris_limit integer
---@field search_debounce_ms integer
---@field rate_limit_retries integer
---@field rate_limit_max_wait_seconds integer
---@field soloist_startup_timeout_ms integer
---@field soloist_poll_interval_ms integer
---@field device_lookup_delay_ms integer
---@field login_timeout_ms integer
---@field notify_options ToastNotifyOptsProps

local home_directory = vim.uv.os_homedir() or ''

---@type MusicConfigProps
return {
  state_directory = vim.fs.joinpath(vim.fn.stdpath 'state', 'music'),
  soloist_data_directory = vim.fs.joinpath(
    vim.env.XDG_DATA_HOME or vim.fs.joinpath(home_directory, '.local', 'share'),
    'soloist'
  ),
  spotify_player_cache_directory = vim.fs.joinpath(
    home_directory,
    '.cache',
    'spotify-player'
  ),
  device_name = vim.uv.os_gethostname(),
  redirect = { host = '127.0.0.1', port = 8989, path = '/login' },
  scopes = {
    'user-read-playback-state',
    'user-modify-playback-state',
    'user-read-currently-playing',
    'playlist-read-private',
    'playlist-read-collaborative',
    'playlist-modify-private',
    'playlist-modify-public',
    'user-library-read',
    'user-library-modify',
  },
  liked_playlist_id = 'liked',
  liked_playlist_name = 'Liked Songs',
  trash_playlist_name = 'Trash',
  page_limit = 50,
  search_limit = 10,
  context_uris_limit = 50,
  search_debounce_ms = 300,
  rate_limit_retries = 5,
  rate_limit_max_wait_seconds = 30,
  soloist_startup_timeout_ms = 10000,
  soloist_poll_interval_ms = 100,
  device_lookup_delay_ms = 1000,
  login_timeout_ms = 300000,
  notify_options = { title = 'Music' },
}
