local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local dap = require 'core.dap.registry'
local docs = require 'core.docs.registry'
local lint = require 'core.linter.registry'
local fmt = require 'core.formatter.registry'
local treesitter = require 'core.treesitter.registry'

---@type string[]
local javascript_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
}

treesitter.record_treesitter 'html'

deps.record_toolchain {
  short = 'ts',
  filetypes = javascript_filetypes,
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
  },
}

fmt.record_fmt {
  lang = javascript_filetypes,
  formatter = 'oxfmt',
  deps = { { depends_on = 'bun', install_command = 'bun i -g oxfmt' } },
}

lint.record_linter {
  lang = javascript_filetypes,
  linter = 'oxlint',
}

deps.record_filetypes {
  pattern = { ['.*%.component%.html'] = 'htmlangular' },
}

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
  filetypes = javascript_filetypes,
  configurations = {
    { program = '${file}' },
    {
      name = 'Attach to process',
      request = 'attach',
      processId = function() return require('dap.utils').pick_process() end,
    },
  },
}

docs.record_docs {
  'html',
  'react',
  'bun',
}

lsp.record_lsp {
  deps = { { install_command = 'bun i -g typescript' } },
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
