return {
  cmd = { vim.fn.expand '~/.go/bin/gopls' },
  ['gopls'] = {
    rootPatterns = { 'go.work', 'go.mod', '.vim/', '.git/', '.hg/' },
    filetypes = { 'go' },
    initializationOptions = {
      usePlaceholders = true,
    },
  },
}
