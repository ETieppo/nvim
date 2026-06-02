return {
  cmd = { vim.fn.expand '~/.cargo/bin/rust-analyzer' },
  settings = {
    rust_analyzer= {
      enable_build_on_save = true,
      build_on_save_step = 'check',
      enable_ast_check_diagnostics = true,
      force_autofix = true,
      warn_style = true,
    },
  },
}
