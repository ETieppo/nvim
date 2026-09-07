local os = require 'utils.os'
local zls_path = os.which 'zls'
local zig_exe_path = os.which 'zig'

return {
  cmd = { zls_path },
  filetypes = { 'zig' },
  root_markers = { 'build.zig' },
  settings = {
    zls = {
      zig_exe_path,
    },
  },
}
