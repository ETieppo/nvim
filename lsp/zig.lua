local zig = vim.fn.exepath 'zig'

return {
  cmd = { 'zls' },
  filetypes = { 'zig', 'zon' },
  root_markers = { 'build.zig', '.git' },
  settings = {
    zls = {
      zig_exe_path = zig ~= '' and zig or nil,
    },
  },
}
