local fmt = require 'core.formatter.registry'
local def = require 'servers.teal.def'

fmt.record_fmt {
  formatter = 'cerulean',
  deps = { { os = def.LUAROCKS_INSTALL 'cerulean' } },
  config = {
    command = 'ceru',
    stdin = false,
    args = {},
  },
}
