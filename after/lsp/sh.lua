local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'bash-language-server',
      install_command = 'bun add -g bash-language-server',
    },
    {
      cmd = 'shellcheck',
      os = {
        macos = 'brew install shellcheck',
        archlinux = 'sudo pacman -S shellcheck',
        windows = 'scoop install shellcheck',
      },
    },
    {
      cmd = 'shfmt',
      os = {
        macos = 'brew install shfmt',
        archlinux = 'pacman -S shfmt',
        windows = 'scoop install shfmt',
      }
    }
  }
}

return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { lang_name, 'bash' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
