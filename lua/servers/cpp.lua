local lang_deps= require 'core.lang_registry'
local lsp = require 'core.lsp'
local dap = require 'core.dap'
local fmt = require 'core.fmt'
local lang_name = require('utils.helpers').get_this_filename()
---@type string[]
local filetypes = { lang_name, 'c' }

lang_deps.record_lang_deps {
  treesitter = filetypes,
  deps = {
    {
      cmd = 'clangd',
      install_command = 'llvm',
      os = { linux = 'clang' },
    },
    { cmd = 'cmake' },
  },
}

fmt.record_fmt {
  lang = filetypes,
  formatter = 'clang-format',
}

dap.record_dap {
  adapter = 'lldb',
  filetypes = filetypes,
  configurations = { dap.build_lldb_launch_configuration() },
}

lsp.record_lsp {
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--completion-style=detailed',
    '--function-arg-placeholders',
    '--fallback-style=llvm',
  },
  filetypes = filetypes,
  root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'CMakeLists.txt',
    'meson.build',
    'configure.ac',
    'Makefile',
    '.git',
  },
  capabilities = {
    offsetEncoding = { 'utf-8', 'utf-16' },
  },
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
