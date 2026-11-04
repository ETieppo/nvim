local lang_mod = require 'langs.core'
local javascript_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
}

lang_mod.record_lang_deps {
  short = 'ts',
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  depends_on = {
    'emmet',
    'oxlint',
  },
  deps = {
    {
      cmd = 'bun',
      os = {
        unix = 'curl -fsSL https://bun.sh/install | bash',
        windows = 'powershell -c "irm bun.sh/install.ps1|iex"',
      },
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

lang_mod.record_fmt {
  lang = javascript_filetypes,
  formatter = 'oxfmt',
}

lang_mod.record_linter {
  lang = javascript_filetypes,
  linter = 'oxlint',
}

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
      executable = {
        command = path,
        args = {
          '${port}',
          '127.0.0.1',
        },
      },
    }
  end,
}

lang_mod.record_dap {
  adapter = 'pwa-node',
  filetypes = javascript_filetypes,
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
  'html',
  'react',
  'bun',
}

return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  filetypes = javascript_filetypes,
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
