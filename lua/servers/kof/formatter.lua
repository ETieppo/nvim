local fmt = require 'core.formatter.registry'

fmt.record_fmt {
  formatter = 'kof_fmt',
  config = {
    command = 'kof',
    args = {
      'fmt',
      '$FILENAME',
      '-w',
    },
    stdin = false,
  },
}
