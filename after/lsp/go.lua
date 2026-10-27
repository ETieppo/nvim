local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
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

lang_mod.record_dap_adapter {
  name = 'delve',
  cmd = 'dlv',
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

lang_mod.record_dap {
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

return {
  cmd = { vim.fn.expand 'gopls' },
  filetypes = { lang_name, 'gomod' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
