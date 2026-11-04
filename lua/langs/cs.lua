local lang_mod = require 'langs.core'
local os_mod = require 'utils.os_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.docs_ignore()

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'clang-format',
}

lang_mod.record_lang_deps {
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
  local sdk_dir = sdks and sdks:match '%[(.-)%]'
  if not sdk_dir then return nil end

  return vim.fs.dirname(sdk_dir)
end

return {
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
