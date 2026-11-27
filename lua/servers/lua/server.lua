local lang_deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

lang_deps.record_toolchain {
  deps = { { cmd = 'lua' } },
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
