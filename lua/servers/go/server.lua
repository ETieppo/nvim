---@module 'dap'

local lsp = require 'core.lsp.registry'
local deps = require 'core.lang.registry'
local dap = require 'core.dap.registry'
local lang_name = require('utils.helpers').get_this_directory_name()
local linter = require 'core.linter.registry'

deps.record_toolchain {
  deps = { { cmd = 'go' } },
}

linter.record_linter {
  linter = 'golangcilint',
  deps = { { cmd = 'golangci-lint' } },
}

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

lsp.record_lsp {
  deps = {
    {
      install_command = 'go install golang.org/x/tools/gopls@latest',
      push_to_path = '.go/bin',
    },
  },
  cmd = { 'gopls' },
  filetypes = { lang_name, 'gomod' },
  root_markers = { 'go.work', 'go.mod', '.git', '.hg' },
  init_options = { usePlaceholders = true },
}
