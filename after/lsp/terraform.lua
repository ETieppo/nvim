require('utils.lang_deps').register_lang_deps({
  lang = "terraform",
  deps = {
    {
      cmd = "terraform-ls",
      os = {
        macos = "brew install terraform-ls",
        archlinux = "yay -S terraform-ls",
        windows = "scoop bucket add main ; scoop install main/terraform-ls"
      }
    },
    {
      cmd = "terraform",
      os = {
        archlinux = "sudo pacman -S terraform",
        macos = "brew tap hashicorp/tap && brew install hashicorp/tap/terraform && brew upgrade hashicorp/tap/terraform",
        windows = "scoop install main/terraform"
      }
    }
  }
})

return {
  cmd = { "terraform-ls", "serve" },
  filetypes = { 'terraform', 'tf' }
}
