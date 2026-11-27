local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'

deps.record_toolchain {
  treesitter = 'dockerfile',
  deps = { { cmd = 'docker' } },
}

lsp.record_lsp {
  deps = {
    {
      depends_on = 'bun',
      install_command = 'bun add -g dockerfile-language-server-nodejs',
    },
  },
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'Dockerfile', 'docker' },
}
