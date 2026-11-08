local docs = require 'core.docs.registry'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_filename()
local wesl_name = 'wesl'
---@type string[]
local filetypes = {
  lang_name,
  wesl_name,
}

docs.docs_ignore()

deps.record_lang_deps {
  short = 'wesl',
  deps = {
    { cmd = 'wgsl-analyzer' },
    {
      cmd = 'wesl',
      depends_on = 'rust',
      install_command = 'cargo install wesl-cli',
    },
    {
      cmd = 'wgslfmt',
      depends_on = 'cargo',
      install_command = 'cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgslfmt --locked',
    },
  },
}

fmt.record_fmt {
  lang = filetypes,
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

vim.filetype.add {
  extension = {
    [wesl_name] = wesl_name,
  },
}

vim.treesitter.language.register(lang_name, wesl_name)

lsp.record_lsp {
  cmd = { 'wgsl-analyzer' },
  filetypes = filetypes,
  root_markers = { 'wesl.toml', '.git' },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
