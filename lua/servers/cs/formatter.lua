local fmt = require 'core.formatter.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

fmt.record_fmt {
  lang = lang_name,
  formatter = 'clang-format',
}
