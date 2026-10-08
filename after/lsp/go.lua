local lang_mod = require('utils.lang')
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps({
  lang = lang_name,
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
  filetypes = { lang_name, 'gomod' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
