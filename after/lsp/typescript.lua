local lang_name = require('utils.helpers').get_this_filename()
local lang_mod = require 'utils.lang_mod'

lang_mod.record_lang_deps {
  short = 'ts',
  deps = {
    {
      cmd = 'bun',
      os = {
        unix = 'curl -fsSL https://bun.sh/install | bash',
        windows = 'powershell -c "irm bun.sh/install.ps1|iex"',
      },
    },
    {
      cmd = 'prettierd',
      install_command = 'bun i -g @fsouza/prettierd',
    },
    {
      cmd = 'tsc',
      install_command = 'bun i -g typescript',
    },
    {
      cmd = 'js-debug-adapter',
      release = {
        repo = 'microsoft/vscode-js-debug',
        asset_pattern = 'js-debug-dap-v[^"]+\\.tar\\.gz',
        wrapper = { runtime = 'bun', entry = 'js-debug/src/dapDebugServer.js' },
      },
    },
  },
}

for _, l in ipairs {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'html',
  'htmlangular',
} do
  lang_mod.record_fmt {
    lang = l,
    formatter = 'prettierd',
  }
end

vim.filetype.add {
  pattern = { ['.*%.component%.html'] = 'htmlangular' },
}

lang_mod.record_dap_adapter {
  name = 'pwa-node',
  cmd = 'js-debug-adapter',
  build = function(path)
    return {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = { command = path, args = { '${port}', '127.0.0.1' } },
    }
  end,
}

lang_mod.record_dap {
  adapter = 'pwa-node',
  filetypes = {
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
  },
  configurations = {
    {
      name = 'Launch file',
      type = 'pwa-node',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      sourceMaps = true,
    },
    {
      name = 'Attach to process',
      type = 'pwa-node',
      request = 'attach',
      processId = function() return require('dap.utils').pick_process() end,
      cwd = '${workspaceFolder}',
      sourceMaps = true,
    },
  },
}

lang_mod.record_docs {
  docs = { 'typescript', 'html', 'angular', 'react', 'bun' },
}

return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = {
    lang_name,
    'javascript',
    'javascriptreact',
    'typescriptreact',
  },

  root_markers = {
    'jsconfig.json',
    'tsconfig.json',
    'package.json',
    '.git',
  },

  init_options = {
    hostInfo = 'neovim',
  },
}
