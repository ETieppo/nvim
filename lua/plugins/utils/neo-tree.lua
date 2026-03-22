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
    zindex = 100,
    hide_root_node = true,
    close_if_last_window = true,
    clipboard = {
      sync = 'global',
    },
    window = {
      position = 'left',
      width = 26,
      zindex = 100,
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
      follow_current_file = { enabled = true },
    },
    buffers = {
      group_empty_dirs = false,
      show_unloaded = true,
    },
  },
}
