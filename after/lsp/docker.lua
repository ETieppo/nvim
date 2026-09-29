require('utils.lang_deps').register_lang_deps({
  lang = "docker",
  deps = {
    {
      cmd = "docker-langserver",
      install_command = "bun add -g dockerfile-language-server-nodejs"
    },
    {
      cmd = "docker",
      os = {
        archlinux = "sudo pacman -S docker --nocomfirm",
        macos = "brew install docker",
        windows = "scoop bucket add main ; scoop install main/docker"
      }
    }
  }
})

return {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { "Dockerfile", "docker" }
}
