local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_filename()

dap.record_dap {
  adapter = 'lldb',
  configurations = { dap.build_lldb_launch_configuration() },
}

lsp.record_lsp {
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
