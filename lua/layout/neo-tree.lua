local plugins = require 'deps.plugins'
local SIGN_CHAR = '¦'
local STAGED_CHAR = '┆'

-- ---@module 'nui.tree'
-- ---@class (partial) NeoTreeIconProps : neotree.Component.Common.Icon
local M = {}

---@return integer|nil
local function find_neotree_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'neo-tree' then
      return win
    end
  end
end

vim.keymap.set('n', '\\', function()
  if not require('layout.database_manager.ui').focus() then
    if find_neotree_window() ~= nil and vim.bo.filetype == 'neo-tree' then
      vim.cmd 'Neotree close'
    else
      vim.cmd 'Neotree reveal'
    end
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
  -- config = function(_, opts)
  --   require('components.material_icons').setup()
  --   require('neo-tree').setup(opts)
  -- end,
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    zindex = 100,
    hide_root_node = true,
    close_if_last_window = true,
    default_component_configs = {
      indent = { with_expanders = false },
      -- ---@type NeoTreeIconProps
      -- icon = {
      --   provider = function(icon, node, state)
      --     local defaults = require 'neo-tree.defaults'
      --     defaults.default_component_configs.icon.provider(icon, node, state)
      --     if node.type == 'directory' then
      --       require('layout.icons.loader').apply_folder_icon(icon, node)
      --     end
      --   end,
      -- },
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

return M
