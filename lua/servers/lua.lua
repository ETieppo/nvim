local lang_deps= require 'core.lang_registry'
local lsp = require 'core.lsp'
local fmt =  require 'core.fmt'
local lang_name = require('utils.helpers').get_this_filename()

lang_deps.record_lang_deps {
  deps = {
    { cmd = 'lua' },
    { cmd = 'lua-language-server' },
    { cmd = 'stylua' },
  },
}

fmt.record_fmt {
  formatter = 'stylua',
}

lsp.record_lsp {
  cmd = { 'lua-language-server' },
  filetypes = { lang_name },
  root_markers = { '.git', '.stylua.toml' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}
