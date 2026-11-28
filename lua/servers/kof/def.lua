---@type LangDefProps
return {
  docs_ignore = true,
  treesitter_ignore = true,
  deps = {
    {
      cmd = 'kfvm',
      os = {
        unix = 'curl -fsSL https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.sh | sh',
        windows = 'irm https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.ps1 | iex',
      },
    },
    {
      cmd = 'kof',
      install_command = 'kfvm u lts',
    },
  },
  filetype_rules = {
    extension = {
      kf = 'kof',
      kof = 'kof',
    },
  },
}
