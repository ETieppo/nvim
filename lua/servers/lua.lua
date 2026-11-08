local lang_deps = require 'core.lang.registry'
local plugins = require 'deps.plugins'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local lang_name = require('utils.helpers').get_this_filename()

lang_deps.record_lang_deps {
  deps = {
    { cmd = 'lua' },
    { cmd = 'lua-language-server' },
    { cmd = 'stylua' },
  },
}

fmt.record_fmt {
  formatter = 'stylua',
}

lsp.record_lsp {
  cmd = { 'lua-language-server' },
  filetypes = { lang_name },
  root_markers = { '.git', '.stylua.toml' },
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        checkThirdParty = false,
        library = { vim.env.VIMRUNTIME },
      },
    },
  },
}

plugins.record {
  'folke/lazydev.nvim',
  ft = 'lua',
  opts = {
    library = {
      { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      '${3rd}/busted/library',
      '${3rd}/luassert/library',
      { path = 'lazy.nvim', words = { 'LazySpec' } },
      { path = 'snacks.nvim', words = { 'Snacks' } },
      { path = 'blink.cmp', words = { 'blink%.cmp' } },
      { path = 'gitsigns.nvim', words = { 'Gitsigns' } },
      { path = 'todo-comments.nvim', words = { 'TodoOptions' } },
      { path = 'neo-tree.nvim', words = { 'neotree' } },
      { path = 'which-key.nvim', words = { 'wk%.' } },
    },
  },
  config = function(_, opts)
    table.insert(require('lazydev.lsp').supported_clients, 'lua')
    require('lazydev').setup(opts)
  end,
}
