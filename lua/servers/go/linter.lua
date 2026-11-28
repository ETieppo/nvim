local lint = require 'core.linter.registry'

lint.record_linter {
  linter = 'golangcilint',
  deps = { { cmd = 'golangci-lint' } },
}
