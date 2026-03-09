require 'settings'
require 'keymaps'
require 'schedules'
require 'auto-commands'
require 'diagnostics'

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  require 'plugins.autoformat',
  require 'plugins.comments',
  require 'plugins.guess-indent',
  require 'plugins.gitsigns',
  require 'plugins.mini',
  require 'plugins.nvim-lspconfig',
  require 'plugins.telescope',
  require 'plugins.theme',
  require 'plugins.tree-sitter',
  require 'plugins.autocomplete',
  require 'plugins.telescope',
  require 'plugins.which-key',
  require 'plugins.debug',
  require 'plugins.indent_line',
  require 'plugins.lint',
  require 'plugins.autopairs',
  require 'plugins.neo-tree',
  require 'plugins.gitsigns',
  require 'plugins.autosave',
  require 'plugins.dash',
  require 'plugins.surround',
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
