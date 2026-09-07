local os = require 'utils.os'
local zls_path = os.expand_bin_path 'zls'
local zig_exe_path = os.expand_bin_path 'zig'

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
