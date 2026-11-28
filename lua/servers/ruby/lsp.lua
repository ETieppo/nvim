local lsp = require 'core.lsp.registry'
local def = require 'servers.ruby.def'

lsp.record_lsp {
  deps = { { install_command = 'gem install ruby-lsp && rbenv rehash' } },
  cmd = { 'ruby-lsp' },
  filetypes = def.filetypes,
  root_markers = { 'sorbet/config', 'Gemfile', '.git' },
}
