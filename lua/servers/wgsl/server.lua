local docs = require 'core.docs.registry'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local deps = require 'core.lang.registry'
local treesitter = require 'core.treesitter.registry'
local lang_name = require('utils.helpers').get_this_directory_name()
local wesl_name = 'wesl'
---@type string[]
local filetypes = {
  lang_name,
  wesl_name,
}

docs.docs_ignore()

deps.record_toolchain {
  short = 'wesl',
  deps = {
    {
      cmd = 'wesl',
      depends_on = 'rust',
      install_command = 'cargo install wesl-cli',
    },
  },
}

fmt.record_fmt {
  lang = filetypes,
  formatter = 'wgslfmt',
  deps = {
    {
      depends_on = 'cargo',
      install_command = 'cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgslfmt --locked',
    },
  },
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

deps.record_filetypes {
  extension = {
    [wesl_name] = wesl_name,
  },
}

treesitter.record_language_filetypes(lang_name, { wesl_name })

lsp.record_lsp {
  cmd = { 'wgsl-analyzer' },
  filetypes = filetypes,
  root_markers = { 'wesl.toml', '.git' },
  on_init = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end,
}
