local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

deps.record_toolchain {}

dap.record_dap {
  adapter = {
    name = 'php',
    cmd = 'php-debug-adapter',
    deps = {
      {
        depends_on = 'bun',
        release = {
          repo = 'xdebug/vscode-php-debug',
          asset_pattern = 'php-debug-[^"]+\\.vsix',
          wrapper = { runtime = 'bun', entry = 'extension/out/phpDebug.js' },
        },
      },
    },
  },
  configurations = { { name = 'Listen for Xdebug', port = 9003 } },
}

lsp.record_lsp {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
