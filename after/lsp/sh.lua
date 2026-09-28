require('utils.lang_deps').register_lang_deps({
  lang = 'sh',
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
      },
    },
  },
})

return {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
  settings = {
    bashIde = {
      globPattern = '*@(.sh|.inc|.bash|.command)',
      shellcheckArguments = { '--external-sources' },
      shfmt = { caseIndent = true, spaceRedirects = true },
    },
  },
}
