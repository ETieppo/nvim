return {
  cmd = { vim.fn.expand '~/.go/bin/gopls' },
  filetypes = { 'go' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
