local os = require 'utils.os'

local jdtls_path = os.is_unix() and '/opt/homebrew/bin/jdtls'
  or '/usr/bin/jdtls'

return {
  cmd = { vim.fn.expand(jdtls_path) },
  filetypes = { 'java' },
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
