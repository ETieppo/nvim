---@type LangDefProps
return {
  short = 'cr',
  deps = { { cmd = 'crystal' } },
  treesitter_install = {
    url = 'https://github.com/crystal-lang-tools/tree-sitter-crystal',
    revision = '50ca9e6fcfb16a2cbcad59203cfd8ad650e25c49',
    queries = 'queries/nvim',
  },
}
