local lang_mod = require 'utils.lang'
local lang_name = require('utils.helpers').get_this_filename()

local root_marker = 'codeterraform-workspace.json'
local server_dir = vim.fn.expand '~/.local/share/io.codeterraform.game/external-ide/server'

lang_mod.ignore_treesitter_install()

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'ct',
  deps = {
    {
      cmd = 'node',
      min_version = '20.0.0',
      os = {
        archlinux = 'sudo pacman -S nodejs',
        macos = 'brew install node',
        windows = 'scoop install nodejs',
      },
    },
    {
      cmd = 'ruff',
      os = {
        archlinux = 'sudo pacman -S ruff',
        macos = 'brew install ruff',
        windows = 'scoop install ruff',
      },
    },
  },
}

local dap_ready = false

local function setup_dap()
  if dap_ready then return end
  dap_ready = true
  local dap = require 'dap'

  dap.adapters.codeterraform = {
    type = 'executable',
    command = 'node',
    args = { server_dir .. '/debug-adapter.cjs' },
  }

  dap.providers.configs.codeterraform = function(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
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
  end
end

return {
  cmd = { 'node', server_dir .. '/server.cjs', '--stdio' },
  filetypes = { 'python' },
  root_markers = { root_marker },
  workspace_required = true,
  on_attach = setup_dap,
}
