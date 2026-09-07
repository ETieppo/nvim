local lua_lsp_path = require('utils.os').expand_bin_path 'lua-language-server'

return {
  cmd = { lua_lsp_path },
  filetypes = { 'lua' },
  root_markers = { '.git', '.stylua.toml' },
}
