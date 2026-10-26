local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()
local filetypes = { lang_name, 'c' }

lang_mod.record_lang_deps {
  lang = lang_name,
  tree_sitter_name = filetypes,
  deps = {
    {
      cmd = 'clangd',
      os = {
        archlinux = 'pacman -S clang',
        macos = 'brew install llvm',
        windows = 'scoop install main/llvm',
      },
    },
    {
      cmd = 'cmake',
      os = {
        archlinux = 'pacman -S cmake',
        macos = 'brew install cmake',
        windows = 'scoop install main/cmake',
      },
    },
  },
}

for _, filetype in ipairs(filetypes) do
  lang_mod.record_fmt {
    lang = filetype,
    formatter = 'clang-format',
  }
end

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
