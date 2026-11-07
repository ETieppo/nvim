local lang_mod = require 'core.lang_registry'
local lsp = require 'core.lsp'

lang_mod.record_lang_deps {
  treesitter = 'dockerfile',
  deps = {
    {
      cmd = 'docker-langserver',
      depends_on = 'bun',
      install_command = 'bun add -g dockerfile-language-server-nodejs',
    },
    { cmd = 'docker' },
  },
}

lsp.record_lsp {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'Dockerfile', 'docker' },
}
