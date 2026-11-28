require('core.linter.registry').record_linter {
  linter = 'ameba',
  deps = {
    {
      os = {
        macos = 'brew tap crystal-ameba/ameba && brew trust --formula crystal-ameba/ameba/ameba && brew install crystal-ameba/ameba/ameba',
      },
    },
  },
  config = { cmd = 'ameba' },
}
