local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lsp.record_lsp {
  cmd = { 'jdtls' },
  filetypes = { lang_name },
  root_markers = {
    'settings.gradle.kts',
    'settings.gradle',
    'build.gradle.kts',
    'build.gradle',
    'pom.xml',
    'gradlew',
    '.git',
  },
  settings = {
    jdtls = {},
  },
}
