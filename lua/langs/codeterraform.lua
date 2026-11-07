---@module 'dap'

local lang_mod = require 'langs.core'

local root_marker = 'codeterraform-workspace.json'
local server_dir =
  vim.fn.expand '~/.local/share/io.codeterraform.game/external-ide/server'

lang_mod.docs_ignore()
lang_mod.treesitter_ignore()

lang_mod.record_lang_deps {
  short = 'ct',
  depends_on = 'bun',
  deps = {
    { cmd = 'ruff' },
  },
}

lang_mod.record_dap_adapter {
  name = 'codeterraform',
  cmd = 'bun',
  args = { server_dir .. '/debug-adapter.cjs' },
}

lang_mod.record_dap {
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

---@type vim.lsp.Config
return {
  cmd = { 'bun', server_dir .. '/server.cjs', '--stdio' },
  filetypes = { 'python' },
  root_markers = { root_marker },
  workspace_required = true,
}
