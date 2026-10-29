local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  deps = {
    { cmd = 'lua' },
    { cmd = 'lua-language-server' },
    { cmd = 'stylua' },
  },
}

lang_mod.record_fmt {
  formatter = 'stylua',
}

---@type vim.lsp.Config
return {
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
