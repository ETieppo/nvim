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
  clangd = {
    root_markers = {
      'compile_commands.json',
      'compile_flags.txt',
      'configure.ac',
      'Makefile',
      'configure.ac',
      'configure.in',
      'config.h.in',
      'meson.build',
      'meson_options.txt',
      'build.ninja',
      '.git',
      'main.c',
      'main.cpp',
      'index.c',
      'index.cpp',
    },
    capabilities = {
      offsetEncoding = { 'utf-16' },
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
}
