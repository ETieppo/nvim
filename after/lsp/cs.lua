local lang_mod = require 'utils.lang_mod'

lang_mod.record_lang_deps {
  tree_sitter_name = 'c_sharp',
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

return {
  cmd = { 'roslyn-language-server', '--stdio', '--autoLoadProjects' },
  filetypes = { 'cs' },
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
