local fmt = require 'core.formatter.registry'

fmt.record_fmt {
  formatter = 'ruff_format',
  deps = { { cmd = 'ruff' } },
}
