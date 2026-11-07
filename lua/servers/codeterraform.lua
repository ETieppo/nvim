---@module 'dap'

local lsp = require 'core.lsp'
local docs = require 'core.docs'
local treesitter = require 'core.treesitter'
local lang_registry = require 'core.lang_registry'
local dap = require 'core.dap'

local root_marker = 'codeterraform-workspace.json'
local server_dir =
  vim.fn.expand '~/.local/share/io.codeterraform.game/external-ide/server'

docs.docs_ignore()
treesitter.treesitter_ignore()

lang_registry.record_lang_deps {
  short = 'ct',
  depends_on = 'bun',
  deps = {
    { cmd = 'ruff' },
  },
}

dap.record_dap_adapter {
  name = 'codeterraform',
  cmd = 'bun',
  args = { server_dir .. '/debug-adapter.cjs' },
}

dap.record_dap {
  adapter = 'codeterraform',
  ---@param buffer integer
  ---@return table[]
  provider = function(buffer)
    local file = vim.api.nvim_buf_get_name(buffer)
    local root = vim.fs.root(file, root_marker)
    if not root then return {} end

    return {
      {
        name = 'Code Terraform: run script in game',
        type = 'codeterraform',
        request = 'launch',
        workspace = root,
        script = file,
      },
      {
        name = 'Code Terraform: attach to running script',
        type = 'codeterraform',
        request = 'attach',
        workspace = root,
        script = file,
      },
    }
  end,
}

lsp.record_lsp {
  cmd = { 'bun', server_dir .. '/server.cjs', '--stdio' },
  filetypes = { 'python' },
  root_markers = { root_marker },
  workspace_required = true,
}
