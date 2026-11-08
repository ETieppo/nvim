local fmt= require 'core.formatter.registry'
local lsp = require 'core.lsp.registry'
local deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_filename()
local terraform_name = 'terraform'

vim.filetype.add {
  extension = {
    [lang_name] = terraform_name,
  },
}

fmt.record_fmt {
  lang = terraform_name,
  formatter = 'tofu_fmt',
}

deps.record_lang_deps {
  treesitter = terraform_name,
  doc = { 'opentofu' },
  short = 'tf',
  deps = {
    { cmd = 'tofu-ls' },
    {
      cmd = 'tofu',
      install_command = 'opentofu',
    },
  },
}

lsp.record_lsp {
  cmd = {
    'tofu-ls',
    'serve',
  },
  filetypes = {
    terraform_name,
    'tf',
    'terraform-vars',
  },
  root_markers = {
    '.terraform',
    '.git',
  },
}
