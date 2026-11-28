---@module 'dap'

local dap = require 'core.dap.registry'
local def = require 'servers.codeterraform.def'

dap.record_dap {
  adapter = {
    name = 'codeterraform',
    cmd = 'bun',
    args = { def.SERVER_DIRECTORY .. '/debug-adapter.cjs' },
  },
  ---@param buffer integer
  ---@return table[]
  provider = function(buffer)
    local file = vim.api.nvim_buf_get_name(buffer)
    local root = vim.fs.root(file, def.ROOT_MARKER)
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
