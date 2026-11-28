local lang_name = require('utils.helpers').get_this_directory_name()

require('core.lsp.registry').record_lsp {
  cmd = { 'crystalline' },
  filetypes = { lang_name },
  root_markers = { 'shard.yml', '.git' },
}
