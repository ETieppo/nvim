---@param rock string
---@return OsInstructionProps
local function luarocks_install(rock)
  return {
    unix = 'sudo luarocks install ' .. rock,
    windows = 'luarocks install ' .. rock,
  }
end

---@type LangDefProps
return {
  short = 'tl',
  docs_ignore = true,
  deps = {
    { cmd = 'luarocks' },
    {
      cmd = 'tl',
      os = luarocks_install 'tl',
    },
    {
      cmd = 'cyan',
      os = luarocks_install 'cyan',
    },
  },
  LUAROCKS_INSTALL = luarocks_install,
}
