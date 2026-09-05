local os = require 'utils.os'
local os_path = os.is_macos and '/opt/homebrew/bin/' or '/usr/bin/zls/'
local zls_path = os_path .. 'zls'
local zig_exe_path = os_path .. 'zig'

return {
  cmd = {zls_path},
  filetypes = { 'zig' },
  root_markers = { 'build.zig' },
  settings = {
    zls = {
      zig_exe_path,
    },
  },
}
