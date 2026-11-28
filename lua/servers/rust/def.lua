---@type LangDefProps
return {
  short = 'rs',
  lsp = 'rust-analyzer',
  deps = {
    {
      cmd = 'rustup',
      os = {
        unix = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
      },
    },
    {
      cmd = 'cargo',
      push_to_path = '.cargo/bin',
      install_command = 'rustup toolchain install stable',
    },
  },
}
