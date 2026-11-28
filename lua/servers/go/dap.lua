---@module 'dap'

local dap = require 'core.dap.registry'

dap.record_dap {
  adapter = {
    name = 'delve',
    cmd = 'dlv',
    deps = { { install_command = 'delve' } },
    configuration_defaults = { program = '${fileDirname}' },
    ---@param path string
    ---@return dap.Adapter
    build = function(path)
      return {
        type = 'server',
        port = '${port}',
        executable = {
          command = path,
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        },
      }
    end,
  },
  configurations = {
    { name = 'Debug package' },
    { name = 'Debug test', mode = 'test' },
  },
}
