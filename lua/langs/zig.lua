local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'langs.core'
local zig = vim.fn.exepath 'zig'

lang_mod.record_lang_deps {
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

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = { lang_mod.build_lldb_launch_configuration() },
}

return {
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
