return {
  cmd = { vim.fn.expand '~/.cargo/bin/rust-analyzer' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'clippy',
      },
      procMacro = {
        enable = true,
      },
      cargo = {
        buildScripts = { enable = true },
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
