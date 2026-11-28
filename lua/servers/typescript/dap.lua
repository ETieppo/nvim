local dap = require 'core.dap.registry'
local def = require 'servers.typescript.def'

dap.record_dap {
  adapter = {
    name = 'pwa-node',
    cmd = 'js-debug-adapter',
    deps = {
      {
        release = {
          repo = 'microsoft/vscode-js-debug',
          asset_pattern = 'js-debug-dap-v[^"]+\\.tar\\.gz',
          wrapper = {
            runtime = 'bun',
            entry = 'js-debug/src/dapDebugServer.js',
          },
        },
      },
    },
    configuration_defaults = { sourceMaps = true },
    ---@param path string
    ---@return dap.Adapter
    build = function(path)
      return {
        type = 'server',
        host = '127.0.0.1',
        port = '${port}',
        executable = {
          command = path,
          args = {
            '${port}',
            '127.0.0.1',
          },
        },
      }
    end,
  },
  filetypes = def.filetypes,
  configurations = {
    { program = '${file}' },
    {
      name = 'Attach to process',
      request = 'attach',
      processId = function() return require('dap.utils').pick_process() end,
    },
  },
}
