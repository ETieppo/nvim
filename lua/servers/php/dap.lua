local dap = require 'core.dap.registry'

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
