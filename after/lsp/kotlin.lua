local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

return {
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
