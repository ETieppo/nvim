local jdtls_path = vim.fn.has 'macunix' == 1 and '/opt/homebrew/bin/jdtls' or '/usr/bin/jdtls'
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
