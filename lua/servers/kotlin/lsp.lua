local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  cmd = { 'kotlin-language-server' },
  filetypes = { lang_name },
  root_markers = {
    'settings.gradle',
    'settings.gradle.kts',
    'build.gradle',
    'build.gradle.kts',
    'pom.xml',
    '.git',
  },
}
