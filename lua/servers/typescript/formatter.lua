require('core.formatter.registry').record_fmt {
  lang = require('servers.typescript.def').filetypes,
  formatter = 'oxfmt',
  deps = { { depends_on = 'bun', install_command = 'bun i -g oxfmt' } },
}
