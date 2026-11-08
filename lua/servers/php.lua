local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_filename()

deps.record_lang_deps {
  depends_on = 'bun',
  deps = {
    {
      cmd = 'php-debug-adapter',
      release = {
        repo = 'xdebug/vscode-php-debug',
        asset_pattern = 'php-debug-[^"]+\\.vsix',
        wrapper = { runtime = 'bun', entry = 'extension/out/phpDebug.js' },
      },
    },
  },
}

dap.record_dap_adapter {
  name = 'php',
  cmd = 'php-debug-adapter',
}

dap.record_dap {
  adapter = 'php',
  configurations = {
    {
      name = 'Listen for Xdebug',
      type = 'php',
      request = 'launch',
      port = 9003,
    },
  },
}

lsp.record_lsp {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
