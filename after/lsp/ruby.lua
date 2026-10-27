local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
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

return {
  cmd = { 'ruby-lsp' },
  filetypes = { lang_name, 'rbs', 'rbx', 'tt' },
  root_markers = { 'sorbet/config', 'Gemfile', '.git' },
}
