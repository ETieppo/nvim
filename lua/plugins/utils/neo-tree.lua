local sign_char = '¦'
local staged_char = '┆'

---@module 'nui.tree'

---@class (partial) NeoTreeIconProps : neotree.Component.Common.Icon

---@module 'lazy'
---@type LazySpec
return {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  version = '*',
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  config = function(_, opts)
    require('components.material_icons').setup()
    require('neo-tree').setup(opts)
  end,
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    zindex = 100,
    hide_root_node = true,
    close_if_last_window = true,
    default_component_configs = {
      indent = { with_expanders = false },
      ---@type NeoTreeIconProps
      icon = {
        provider = function(icon, node, state)
          local defaults = require 'neo-tree.defaults'
          defaults.default_component_configs.icon.provider(icon, node, state)
          if node.type == 'directory' then
            require('components.material_icons').apply_folder_icon(icon, node)
          end
        end,
      },
      git_status = {
        symbols = {
          added = sign_char,
          deleted = sign_char,
          modified = sign_char,
          renamed = sign_char,
          untracked = sign_char,
          ignored = sign_char,
          unstaged = sign_char,
          conflict = sign_char,
          staged = staged_char,
        },
      },
    },
    clipboard = {
      sync = 'global',
    },
    window = {
      position = 'left',
      width = 30,
      zindex = 100,
    },
    nesting_rules = {
      ['package.json'] = { pattern = '^package%.json$', files = { 'yarn*' } },
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
      use_libuv_file_watcher = true,
      follow_current_file = { enabled = true },
    },
    buffers = {
      group_empty_dirs = false,
      show_unloaded = true,
    },
  },
}
