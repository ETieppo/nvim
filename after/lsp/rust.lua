require('utils.lang_deps').register_lang_deps({
  lang = 'rust',
  deps = {
    {
      cmd = 'rustup',
      os = {
        unix = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
        windows = 'scoop install rustup',
      },
    },
    {
      cmd = 'cargo',
      install_command = 'rustup toolchain install stable',
    },
    {
      cmd = 'rust-analyzer',
      install_command = 'rustup component add rust-analyzer',
    },
  },
})

return {
  cmd = { vim.fn.expand 'rust-analyzer' },
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
