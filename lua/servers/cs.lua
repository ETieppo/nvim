local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local docs = require 'core.docs.registry'
local fmt = require 'core.formatter.registry'
local os_mod = require 'deps.sys'
local lang_name = require('utils.helpers').get_this_filename()

docs.docs_ignore()

fmt.record_fmt {
  lang = lang_name,
  formatter = 'clang-format',
}

deps.record_lang_deps {
  treesitter = 'c_sharp',
  deps = {
    {
      cmd = 'dotnet',
      install_command = 'dotnet-sdk',
      os = { macos = 'dotnet' },
    },
    {
      cmd = 'roslyn-language-server',
      install_command = 'dotnet tool install --global roslyn-language-server --prerelease',
      push_env_source = '.dotnet/tools',
    },
  },
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
  cmd = {
    'roslyn-language-server',
    '--stdio',
    '--autoLoadProjects',
  },
  filetypes = { lang_name },
  cmd_env = {
    DOTNET_ROOT = find_dotnet_root(),
  },
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
