local fmt = require 'core.formatter.registry'
local def = require 'servers.json.def'

fmt.record_fmt {
  lang = def.filetypes,
  formatter = 'oxfmt',
}
