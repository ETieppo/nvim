local lua_lsp_path = require('utils.os').which 'lua-language-server'

return {
  cmd = { lua_lsp_path },
  filetypes = { 'lua' },
  root_markers = { '.git', '.stylua.toml' },
}
