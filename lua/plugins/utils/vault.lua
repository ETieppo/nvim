return {
  'epwalsh/obsidian.nvim',
  version = '*',
  ft = 'markdown',
  opts = {
    workspaces = {
      {
        name = 'vault',
        path = '~/.vault',
      },
    },
  },
}
