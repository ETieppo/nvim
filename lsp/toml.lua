return {
  cmd = {
    'taplo',
    'lsp',
    'stdio',
  },
  filetypes = { 'toml' },
  toml = {
    root_markers = {
      'Cargo.toml',
      '.taplo.toml',
      'taplo.toml',
      '.git',
    },
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true,
    },
  },
}
