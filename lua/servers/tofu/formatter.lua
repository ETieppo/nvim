local fmt = require 'core.formatter.registry'
local def = require 'servers.tofu.def'

fmt.record_fmt {
  lang = def.TERRAFORM,
  formatter = 'tofu_fmt',
  deps = { { cmd = 'tofu' } },
}
