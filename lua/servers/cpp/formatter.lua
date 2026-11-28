local fmt = require 'core.formatter.registry'
local def = require 'servers.cpp.def'

fmt.record_fmt {
  lang = def.filetypes,
  formatter = 'clang-format',
  deps = { { os = { linux = 'clang' } } },
}
