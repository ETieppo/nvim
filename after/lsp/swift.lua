local lang_mod = require 'utils.lang_mod'
local dap_mod = require 'utils.dap_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = { dap_mod.build_lldb_launch_configuration() },
}

return {
  cmd = { 'sourcekit-lsp' },
  filetypes = { lang_name },
  root_markers = {
    '.git',
    'compile_commands.json',
    '.sourcekit-lsp',
    'Package.swift',
  },
  get_language_id = function(_, ftype) return ftype end,
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
    textDocument = {
      diagnostic = {
        dynamicRegistration = true,
        relatedDocumentSupport = true,
      },
    },
  },
}
