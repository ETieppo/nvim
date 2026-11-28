---@type LangDefProps
return {
  treesitter = 'c_sharp',
  docs_ignore = true,
  deps = {
    {
      cmd = 'dotnet',
      install_command = 'dotnet-sdk',
      os = { macos = 'dotnet' },
    },
  },
}
