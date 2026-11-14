local plugins = require 'deps.plugins'
local SIGN_CHAR = '¦'
local STAGED_CHAR = '┆'

vim.keymap.set('n', '\\', function()
  if not require('layout.database_manager.ui').focus() then
    vim.cmd 'Neotree reveal'
  end
end, {
  desc = 'Focus DBUI / Neotree reveal',
  silent = true,
})

---@module 'lazy'
---@type LazySpec
plugins.record {
  'nvim-neo-tree/neo-tree.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  version = '*',
  cmd = 'Neotree',
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    zindex = 100,
    hide_root_node = true,
    close_if_last_window = true,
    default_component_configs = {
      indent = { with_expanders = false },
      git_status = {
        symbols = {
          added = SIGN_CHAR,
          deleted = SIGN_CHAR,
          modified = SIGN_CHAR,
          renamed = SIGN_CHAR,
          untracked = SIGN_CHAR,
          ignored = SIGN_CHAR,
          unstaged = SIGN_CHAR,
          conflict = SIGN_CHAR,
          staged = STAGED_CHAR,
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
