local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'rb',
  deps = {
    {
      cmd = 'rbenv',
      os = {
        macos = 'brew install rbenv ruby-build',
        archlinux = 'pacman -S rbenv ruby-build',
        windows = 0,
      },
    },
    {
      cmd = 'ruby',
      min_version = '3.0.0',
      version_cmd = "ruby -e 'print RUBY_VERSION'",
      os = {
        unix = 'V=$(rbenv install -l | grep -E "^[0-9]+(\\.[0-9]+)*$" | tail -1)'
          .. ' && rbenv install -s "$V" && rbenv global "$V"',
        windows = 0,
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
