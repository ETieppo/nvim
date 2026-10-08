local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_linter {
  lang = lang_name,
  linter = 'markdownlint-cli2'
}

return {}
