local lang_mod = require 'utils.lang_mod'
local install =
  'dotnet tool install --global roslyn-language-server --prerelease'

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
      os = {
        unix = install
          .. [[ && (grep -q '.dotnet/tools' ~/.zshrc || echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.zshrc)]],
        windows = install,
      },
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
