local lsp = require 'core.lsp.registry'
local def = require 'servers.zig.def'

local zig = vim.fn.exepath 'zig'

lsp.record_lsp {
  deps = { { install_command = 'zvm install lts --zls' } },
  cmd = { 'zls' },
  filetypes = def.filetypes,
  root_markers = { 'build.zig', '.git' },
  settings = {
    zls = {
      zig_exe_path = zig ~= '' and zig or nil,
      enable_build_on_save = true,
      warn_style = true,
    },
  },
}
