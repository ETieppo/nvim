local lang_mod = require 'langs.core'
local lang_name = require('utils.helpers').get_this_filename()
---@type string[]
local filetypes = { lang_name, 'c' }

lang_mod.record_lang_deps {
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

lang_mod.record_fmt {
  lang = filetypes,
  formatter = 'clang-format',
}

lang_mod.record_dap {
  adapter = 'lldb',
  filetypes = filetypes,
  configurations = { lang_mod.build_lldb_launch_configuration() },
}

---@type vim.lsp.Config
return {
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
