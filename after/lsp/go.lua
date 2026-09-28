require('utils.lang_deps').register_lang_deps({
  lang = 'go',
  deps = {
    {
      cmd = 'go',
      os = {
        macos = 'brew install go',
        windows = 'scoop install main/go',
        archlinux = 'pacman -S go',
      },
    },
    {
      cmd = 'gopls',
      os = {
        unix = 'go install golang.org/x/tools/gopls@latest && echo export PATH=$PATH:$(go env GOPATH)/bin >> ~/.zshrc',
        windows = 'go install golang.org/x/tools/gopls@latest',
      },
    },
  },
})

return {
  cmd = { vim.fn.expand 'gopls' },
  filetypes = { 'go', 'gomod' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
