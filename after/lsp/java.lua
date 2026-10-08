local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

return {
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
    jdtls = {
      enable_build_on_save = true,
      build_on_save_step = 'check',
      enable_ast_check_diagnostics = true,
      force_autofix = true,
      warn_style = true,
    },
  },
}
