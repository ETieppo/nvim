local zig = vim.fn.exepath 'zig'

require('utils.lang_deps').register_lang_deps({
  lang = 'zig',
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
})

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
