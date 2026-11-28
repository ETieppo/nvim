local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()
local os_mod = require 'deps.sys'

local ROSLYN_COMMAND = {
  'roslyn-language-server',
  '--stdio',
  '--autoLoadProjects',
}

---@return string|nil
local function find_dotnet_root()
  local dotnet = os_mod.which 'dotnet'
  if not dotnet then return nil end

  local sdks = os_mod.read_program_stdout { dotnet, '--list-sdks' }
  ---@type string|nil
  local sdk_dir = sdks and sdks:match '%[(.-)%]'
  if not sdk_dir then return nil end

  return vim.fs.dirname(sdk_dir)
end

lsp.record_lsp {
  deps = {
    {
      cmd = 'roslyn-language-server',
      install_command = 'dotnet tool install --global roslyn-language-server --prerelease',
      push_to_path = '.dotnet/tools',
    },
  },
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start(ROSLYN_COMMAND, dispatchers, {
      cwd = config.cmd_cwd or config.root_dir,
      env = { DOTNET_ROOT = find_dotnet_root() or '' },
      detached = config.detached,
    })
  end,
  filetypes = { lang_name },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(
      bufnr,
      function(name) return name:match '%.slnx?$' ~= nil end
    ) or vim.fs.root(
      bufnr,
      function(name) return name:match '%.csproj$' ~= nil end
    ) or vim.fs.root(bufnr, '.git') or vim.fs.dirname(
      vim.api.nvim_buf_get_name(bufnr)
    )
    on_dir(root)
  end,
}
