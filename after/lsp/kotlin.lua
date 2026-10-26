local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_dap_adapter {
  name = 'kotlin',
  cmd = 'kotlin-debug-adapter',
  build = function(path) return { type = 'executable', command = path } end,
}

lang_mod.record_dap {
  adapter = 'kotlin',
  configurations = {
    {
      name = 'Launch',
      type = 'kotlin',
      request = 'launch',
      projectRoot = '${workspaceFolder}',
      mainClass = function() return vim.fn.input 'Main class: ' end,
    },
  },
}

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
