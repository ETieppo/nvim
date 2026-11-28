---@type LangDefProps
return {
  short = 'ts',
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  depends_on = {
    'emmet',
    'oxlint',
  },
  deps = {
    {
      cmd = 'bun',
      os = {
        unix = 'curl -fsSL https://bun.sh/install | bash',
        windows = 'powershell -c "irm bun.sh/install.ps1|iex"',
      },
    },
  },
  treesitter = { 'typescript', 'html' },
  doc = { 'typescript', 'html', 'react', 'bun' },
  filetype_rules = {
    pattern = { ['.*%.component%.html'] = 'htmlangular' },
  },
}
