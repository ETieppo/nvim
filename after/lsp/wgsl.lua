local lang_mod = require 'utils.lang_mod'

lang_mod.record_lang_deps {
  deps = {
    { cmd = 'wgsl-analyzer' },
    {
      cmd = 'wgslfmt',
      depends_on = 'cargo',
      install_command = 'cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgslfmt --locked',
    },
  },
}

lang_mod.record_fmt {
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
