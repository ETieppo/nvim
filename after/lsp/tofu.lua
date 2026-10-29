local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()
local terraform_name = 'terraform'

vim.filetype.add {
  extension = {
    [lang_name] = terraform_name,
  },
}

lang_mod.record_fmt {
  lang = terraform_name,
  formatter = 'tofu_fmt',
}

lang_mod.record_lang_deps {
  tree_sitter_name = terraform_name,
  short = 'tf',
  deps = {
    { cmd = 'tofu-ls' },
    {
      cmd = 'tofu',
      install_command = 'opentofu',
    },
  },
}

return {
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
