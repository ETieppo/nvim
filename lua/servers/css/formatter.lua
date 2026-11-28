local fmt = require 'core.formatter.registry'
local def = require 'servers.css.def'

fmt.record_fmt {
  lang = def.filetypes,
  formatter = 'prettierd',
}
