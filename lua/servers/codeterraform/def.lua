local ROOT_MARKER = 'codeterraform-workspace.json'

---@type LangDefProps
return {
  short = 'ct',
  filetypes = { 'python' },
  deps = { { cmd = 'ruff' } },
  treesitter_ignore = true,
  docs_ignore = true,
  ROOT_MARKER = ROOT_MARKER,
  SERVER_DIRECTORY = vim.fn.expand '~/.local/share/io.codeterraform.game/external-ide/server',
}
