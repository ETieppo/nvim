local M = {}

---@enum SoloistCommandEnum
M.SoloistCommandEnum = {
  play = 'play',
  pause = 'pause',
  skip_next = 'skip_next',
  skip_prev = 'skip_prev',
  seek = 'seek',
  set_shuffle = 'set_shuffle',
  add_to_queue = 'add_to_queue',
  activate = 'activate',
}

---@enum SoloistEventEnum
M.SoloistEventEnum = {
  auth_state = 'auth_state',
  playback_state = 'playback_state',
  track_changed = 'track_changed',
  playback_changed = 'playback_changed',
  options_changed = 'options_changed',
  error = 'error',
}

---@enum SoloistPlaybackStatusEnum
M.SoloistPlaybackStatusEnum = {
  idle = 'idle',
  playing = 'playing',
  paused = 'paused',
  buffering = 'buffering',
}

return M
