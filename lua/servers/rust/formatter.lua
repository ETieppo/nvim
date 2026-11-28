require('core.formatter.registry').record_fmt {
  formatter = 'rustfmt',
  deps = { { install_command = 'rustup component add rustfmt' } },
}
