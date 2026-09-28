require('utils.lang_deps').register_lang_deps({
  lang = 'ruby',
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
})

return {
  cmd = { 'ruby-lsp' },
  filetypes = { 'ruby', 'rbs' },
  root_markers = { 'sorbet/config', 'Gemfile', '.git' },
}
