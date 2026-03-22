return {
  'jellydn/hurl.nvim',
  dependencies = {
    'MunifTanjim/nui.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    {
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown' },
      },
      ft = { 'markdown' },
    },
  },
  ft = 'hurl',
  opts = {
    debug = false,
    show_notification = false,
    mode = 'split',
    formatters = {
      json = { 'jq' },
      html = {
        'prettier',
        '--parser',
        'html',
      },
      xml = {
        'tidy',
        '-xml',
        '-i',
        '-q',
      },
    },
    mappings = {
      close = 'q',
      next_panel = '<C-n>', -- Move to the next response popup window
      prev_panel = '<C-p>', -- Move to the previous response popup window
    },
  },
  keys = {
    { '<leader>ra', '<cmd>HurlRunner<CR>', desc = '[R]equest [A]ll' },
    { '<leader>rr', '<cmd>HurlRunnerAt<CR>', desc = '[R]equest [R]un' },
    -- { '<leader>re', '<cmd>HurlRunnerToEntry<CR>', desc = '[R]equest [E]ntry' },
    { '<leader>reof', '<cmd>HurlRunnerToEnd<CR>', desc = '[R]equest [E]end [O]f [F]ile' },
    { '<leader>rtm', '<cmd>HurlToggleMode<CR>', desc = '[R]equest [T]oggle [M]ode' },
    { '<leader>rvm', '<cmd>HurlVerbose<CR>', desc = '[R]equest [V]erbose [M]ode' },
    { '<leader>rvvm', '<cmd>HurlVeryVerbose<CR>', desc = 'R]equest [V]ery [V]erbose [M]ode' },
    { '<leader>r', ':HurlRunner<CR>', desc = 'Hurl Runner', mode = 'v' },
  },
}
