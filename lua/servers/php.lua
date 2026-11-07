local dap = require 'core.dap'
local lsp = require 'core.lsp'
local lang_deps= require 'core.lang_registry'
local lang_name = require('utils.helpers').get_this_filename()

lang_deps.record_lang_deps {
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
