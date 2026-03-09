---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    clipboard = {
      sync = 'global',
    },
    window = {
      position = 'left',
      width = 32,
    },
    nesting_rules = {
      ['package.json'] = { pattern = '^package%.json$', files = { 'yarn*' } },
      ['Cargo.toml'] = { '*.toml' },
      ['docker'] = {
        pattern = '^dockerfile$',
        ignore_case = true,
        files = { '.dockerignore', 'docker-compose.*', 'dockerfile*' },
      },
    },
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_ignored = false,
        never_show = {
          '.DS_Store',
          '.git',
        },
      },
      group_empty_dirs = false,
      use_libuv_file_watcher = false,
    },
    buffers = {
      group_empty_dirs = false,
      show_unloaded = true,
    },
  },
}
