local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()
local def = require 'servers.teal.def'

lsp.record_lsp {
  deps = { { os = def.LUAROCKS_INSTALL 'teal-language-server' } },
  cmd = { 'teal-language-server', '--verbose=false', '--log-mode=none' },
  filetypes = { lang_name },
  root_markers = { '.git', 'tlconfig.lua' },
}
