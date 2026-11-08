local lang_deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_filename()

lang_deps.record_lang_deps {
  short = 'rb',
  deps = {
    { cmd = 'rbenv' },
    { cmd = 'ruby-build' },
    {
      cmd = 'ruby',
      min_version = '3',
      push_env_source = '.rbenv/shims',
      os = {
        unix = 'rbenv install -s ruby && rbenv global "$(ruby-build --resolve ruby)"',
      },
    },
    {
      cmd = 'ruby-lsp',
      install_command = 'gem install ruby-lsp && rbenv rehash',
    },
  },
}

lsp.record_lsp {
  cmd = { 'ruby-lsp' },
  filetypes = { lang_name, 'rbs', 'rbx', 'tt' },
  root_markers = { 'sorbet/config', 'Gemfile', '.git' },
}
