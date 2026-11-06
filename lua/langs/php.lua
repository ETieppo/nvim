local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
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

lang_mod.record_dap_adapter {
  name = 'php',
  cmd = 'php-debug-adapter',
}

lang_mod.record_dap {
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

---@type vim.lsp.Config
return {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
