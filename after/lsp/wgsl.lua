local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()
local wesl_name = 'wesl'
local filetypes = {
  lang_name,
  wesl_name,
}

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

for _, filetype in ipairs(filetypes) do
  lang_mod.record_fmt {
    lang = filetype,
    formatter = 'wgslfmt',
    config = {
      stdin = true,
      command = 'wgslfmt',
      args = {
        '-',
        '--silent',
        '--config',
        'indent_width=2',
        '--config',
        'max_line_width=80',
      },
    },
  }
end

vim.filetype.add {
  extension = {
    [wesl_name] = wesl_name,
  },
}

vim.treesitter.language.register(lang_name, wesl_name)

---@type vim.lsp.Config
return {
  cmd = { 'wgsl-analyzer' },
  filetypes = filetypes,
  root_markers = { 'wesl.toml', '.git' },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
