local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  short = 'rb',
  deps = {
    { cmd = 'rbenv' },
    { cmd = 'ruby-build' },
    {
      cmd = 'ruby',
      min_version = '3.0.0',
      version_cmd = "ruby -e 'print RUBY_VERSION'",
      os = {
        unix = 'V=$(rbenv install -l | grep -E "^[0-9]+(\\.[0-9]+)*$" | tail -1)'
          .. ' && rbenv install -s "$V" && rbenv global "$V"',
      },
    },
    { cmd = 'ruby-lsp', install_command = 'gem install ruby-lsp' },
  },
}

return {
  cmd = { 'ruby-lsp' },
  filetypes = { lang_name, 'rbs', 'rbx', 'tt' },
  root_markers = { 'sorbet/config', 'Gemfile', '.git' },
}
