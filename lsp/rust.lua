return {
  cmd = { vim.fn.expand '~/.cargo/bin/rust-analyzer' },
  filetypes = { 'rust' },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'check',
      },
      procMacro = {
        enable = true,
      },
      cargo = {
        buildScripts = { enable = true },
        targetDir = true,
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
