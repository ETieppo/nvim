return {
  'maskudo/devdocs.nvim',
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>dds',
      mode = 'n',
      '<cmd>DevDocs get<cr>',
      desc = '[D]ev[D]ocs [S]earch',
    },
    {
      '<leader>ddi',
      mode = 'n',
      '<cmd>DevDocs install<cr>',
      desc = '[D]ev[D]ocs [I]nstall',
    },
    {
      '<leader>ddd',
      mode = 'n',
      '<cmd>DevDocs delete<cr>',
      desc = '[D]ev[D]ocs [D]elete',
    },
  },
  opts = {
    ensure_installed = {
      'html',
      'css',
      'http',
      'tailwindcss',
      'angular',
      'react',
      'typescript',
      'rust',
      'git',
      'node',
      'bash',
      'bun',
      'docker',
    },
  },
}
