local lang_mod = require 'utils.lang_mod'
local ReleaseAdapter = require 'utils.release_adapter'
local ArchiveFormatEnum = require 'utils.enums.archive_format_enum'
local lang_name = require('utils.helpers').get_this_filename()

local php_debug_adapter = ReleaseAdapter.new {
  name = 'php-debug-adapter',
  repo = 'xdebug/vscode-php-debug',
  asset_pattern = 'php-debug-[^"]+\\.vsix',
  archive_format = ArchiveFormatEnum.zip,
  wrapper = { runtime = 'bun', entry = 'extension/out/phpDebug.js' },
}

php_debug_adapter:add_to_path()

lang_mod.record_lang_deps {
  depends_on = 'bun',
  deps = {
    {
      cmd = 'php-debug-adapter',
      os = { unix = php_debug_adapter:build_install_command() },
    },
  },
}

lang_mod.record_dap_adapter {
  name = 'php',
  cmd = 'php-debug-adapter',
  build = function(path) return { type = 'executable', command = path } end,
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

return {
  cmd = { 'phpantom_lsp' },
  filetypes = { lang_name },
  root_markers = { '.phpantom.toml', '.git', 'composer.json' },
}
