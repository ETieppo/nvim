local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  doc = { 'openjdk' },
  deps = {
    {
      cmd = 'java',
      min_version = '21',
      os = {
        linux = 'jdk-openjdk',
        macos = 'openjdk',
        windows = 'java/openjdk',
      },
    },
    { cmd = 'jdtls' },
  },
}

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
    jdtls = {},
  },
}
