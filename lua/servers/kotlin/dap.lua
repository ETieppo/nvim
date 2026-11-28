local dap = require 'core.dap.registry'

dap.record_dap {
  adapter = {
    name = 'kotlin',
    cmd = 'kotlin-debug-adapter',
    deps = {
      {
        release = {
          repo = 'fwcd/kotlin-debug-adapter',
          asset_pattern = 'adapter\\.zip',
          bin_subdir = 'adapter/bin',
        },
      },
    },
  },
  configurations = {
    {
      name = 'Launch',
      projectRoot = '${workspaceFolder}',
      mainClass = function() return vim.fn.input 'Main class: ' end,
    },
  },
}
