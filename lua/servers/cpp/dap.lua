local dap = require 'core.dap.registry'
local def = require 'servers.cpp.def'

dap.record_dap {
  adapter = 'lldb',
  filetypes = def.filetypes,
}
