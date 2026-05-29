return {
  cmd = {
    'clangd',
    '--header-insertion-decorators=0',
    '--background-index',
    '--clang-tidy',
    '--clang-tidy-checks=-llvm-header-guard,-llvm-copyright',
  },
}
