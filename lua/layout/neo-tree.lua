local plugins = require 'deps.plugins'
local sign_chars = require 'layout.git.sign_chars'

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
          added = sign_chars.unstaged,
          deleted = sign_chars.unstaged,
          modified = sign_chars.unstaged,
          renamed = sign_chars.unstaged,
          untracked = sign_chars.unstaged,
          ignored = sign_chars.unstaged,
          unstaged = sign_chars.unstaged,
          conflict = sign_chars.unstaged,
          staged = sign_chars.staged,
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
