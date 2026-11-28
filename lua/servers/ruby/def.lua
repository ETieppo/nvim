---@type LangDefProps
return {
  short = 'rb',
  filetypes = { 'ruby', 'rbs', 'rbx', 'tt' },
  deps = {
    { cmd = 'rbenv' },
    { cmd = 'ruby-build' },
    {
      cmd = 'ruby',
      min_version = '3',
      push_to_path = '.rbenv/shims',
      os = {
        unix = 'rbenv install -s ruby && rbenv global "$(ruby-build --resolve ruby)"',
      },
    },
  },
}
