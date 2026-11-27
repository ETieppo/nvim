local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local docs = require 'core.docs.registry'
local lang_name = require('utils.helpers').get_this_filename()

---@param rock string
---@return OsInstructionProps
local function luarocks_install(rock)
  return {
    unix = 'sudo luarocks install ' .. rock,
    windows = 'luarocks install ' .. rock,
  }
end

docs.docs_ignore()

deps.record_toolchain {
  short = 'tl',
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
}

fmt.record_fmt {
  formatter = 'cerulean',
  deps = { { os = luarocks_install 'cerulean' } },
  config = {
    command = 'ceru',
    stdin = false,
    args = {},
  },
}

lsp.record_lsp {
  deps = { { os = luarocks_install 'teal-language-server' } },
  cmd = { 'teal-language-server', '--verbose=false', '--log-mode=none' },
  filetypes = { lang_name },
  root_markers = { '.git', 'tlconfig.lua' },
}
