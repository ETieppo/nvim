local dap = require 'core.dap.registry'
local lsp = require 'core.lsp.registry'
local lang_deps = require 'core.lang.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lang_deps.record_toolchain { depends_on = 'java' }

dap.record_dap {
  adapter = {
    name = 'kotlin',
    cmd = 'kotlin-debug-adapter',
    deps = {
      {
        release = {
          repo = 'fwcd/kotlin-debug-adapter',
          asset_pattern = 'adapter\\.zip',
          bin_subdir = 'adapter/bin',
        },
      },
    },
  },
  configurations = {
    {
      name = 'Launch',
      projectRoot = '${workspaceFolder}',
      mainClass = function() return vim.fn.input 'Main class: ' end,
    },
  },
}

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
