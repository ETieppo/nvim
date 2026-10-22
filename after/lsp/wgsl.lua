local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'wgsl-analyzer',
      os = {
        archlinux = 'yay -S wgsl-analyzer',
        macos = 'brew install wgsl-analyzer',
      },
    },
    {
      depends_on = 'rust',
      cmd = 'wgslfmt',
      install_command = 'cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgslfmt --locked',
    },
  },
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'wgslfmt',
  config = {
    stdin = true,
    command = 'wgslfmt',
    args = { '-', '--config', 'indent_width=2' },
  },
}

vim.filetype.add {
  extension = {
    wesl = 'wesl',
  },
}
---@type vim.lsp.Config
return {
  cmd = { 'wgsl-analyzer' },
  filetypes = { 'wgsl', 'wesl' },
  root_markers = { 'wesl.toml', '.git' },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
