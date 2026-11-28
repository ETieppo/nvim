local WESL = 'wesl'

---@type LangDefProps
return {
  short = 'wesl',
  filetypes = { 'wgsl', WESL },
  docs_ignore = true,
  deps = {
    {
      cmd = 'wesl',
      depends_on = 'rust',
      install_command = 'cargo install wesl-cli',
    },
  },
  filetype_rules = {
    extension = {
      [WESL] = WESL,
    },
  },
  treesitter_filetypes = { WESL },
}
