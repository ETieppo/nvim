local lang_mod = require 'langs.core'



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

return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'Dockerfile', 'docker' },
}
