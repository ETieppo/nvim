local lang_mod = require 'utils.lang_mod'

lang_mod.record_lang_deps {
  tree_sitter_name = 'dockerfile',
  deps = {
    {
      cmd = 'docker-langserver',
      depends_on = 'bun',
      install_command = 'bun add -g dockerfile-language-server-nodejs',
    },
    { cmd = 'docker' },
  },
}

lang_mod.record_docs { docs = { 'docker' } }

return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'Dockerfile', 'docker' },
}
