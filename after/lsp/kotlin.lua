local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  depends_on = 'java',
  deps = {
    {
      cmd = 'kotlin-debug-adapter',
      release = {
        repo = 'fwcd/kotlin-debug-adapter',
        asset_pattern = 'adapter\\.zip',
        bin_subdir = 'adapter/bin',
      },
    },
  },
}

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
