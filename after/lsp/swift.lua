local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

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
