local fmt = require 'core.formatter.registry'
local def = require 'servers.wgsl.def'

fmt.record_fmt {
  lang = def.filetypes,
  formatter = 'wgslfmt',
  deps = {
    {
      depends_on = 'cargo',
      install_command = 'cargo install --git https://github.com/wgsl-analyzer/wgsl-analyzer wgslfmt --locked',
    },
  },
  config = {
    stdin = true,
    command = 'wgslfmt',
    args = {
      '-',
      '--silent',
      '--config',
      'indent_width=2',
      '--config',
      'max_line_width=80',
    },
  },
}
