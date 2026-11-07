---@module 'dap'

local lsp = require 'core.lsp'
local lang_deps= require 'core.lang_registry'
local dap = require 'core.dap'
local lang_name = require('utils.helpers').get_this_filename()

lang_deps.record_lang_deps {
  deps = {
    { cmd = 'go' },
    {
      cmd = 'gopls',
      install_command = 'go install golang.org/x/tools/gopls@latest',
      push_env_source = 'go/bin',
    },
    { cmd = 'dlv', install_command = 'delve' },
  },
}

dap.record_dap_adapter {
  name = 'delve',
  cmd = 'dlv',
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
}

dap.record_dap {
  adapter = 'delve',
  configurations = {
    {
      name = 'Debug package',
      type = 'delve',
      request = 'launch',
      program = '${fileDirname}',
      cwd = '${workspaceFolder}',
    },
    {
      name = 'Debug test',
      type = 'delve',
      request = 'launch',
      mode = 'test',
      program = '${fileDirname}',
      cwd = '${workspaceFolder}',
    },
  },
}

lsp.record_lsp {
  cmd = { vim.fn.expand 'gopls' },
  filetypes = { lang_name, 'gomod' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
