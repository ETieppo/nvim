---@type LangDefProps
return {
  doc = { 'openjdk' },
  deps = {
    {
      cmd = 'java',
      min_version = '21',
      os = {
        linux = 'jdk-openjdk',
        macos = 'openjdk',
        windows = 'java/openjdk',
      },
    },
  },
}
