local lang_name = require('utils.helpers').get_this_filename()
local lsp = require 'core.lsp.registry'
local dap = require 'core.dap.registry'
local deps= require 'core.lang.registry'
local zig = vim.fn.exepath 'zig'

deps.record_lang_deps {
  deps = {
    {
      cmd = 'zvm',
      os = {
        unix = 'curl https://www.zvm.app/install.sh | bash',
        windows = 'irm https://www.zvm.app/install.ps1 | iex',
      },
    },
    {
      cmd = 'zig',
      install_command = 'zvm install lts',
    },
    {
      cmd = 'zls',
      install_command = 'zvm install lts --zls',
    },
  },
}

dap.record_dap {
  adapter = 'lldb',
  configurations = { dap.build_lldb_launch_configuration() },
}

lsp.record_lsp {
  cmd = { 'zls' },
  filetypes = { lang_name, 'zon' },
  root_markers = { 'build.zig', '.git' },
  settings = {
    zls = {
      zig_exe_path = zig ~= '' and zig or nil,
      enable_build_on_save = true,
      warn_style = true,
    },
  },
}
