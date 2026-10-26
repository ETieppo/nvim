local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  lang = lang_name,
  short = 'py',
  deps = {
    {
      cmd = 'python3',
      os = {
        archlinux = 'sudo pacman -S python3',
        brew = 'brew install python3',
        windows = 'scoop install python',
      },
    },
    {
      cmd = 'pyright-langserver',
      os = {
        macos = 'brew -S pyright',
        archlinux = 'pacman -S pyright',
      },
    },
    {
      cmd = 'ruff',
      os = {
        macos = 'brew install ruff',
        archlinux = 'sudo pacman -S ruff',
        windows = 'scoop install ruff',
      },
    },
  },
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'ruff_format',
}

lang_mod.record_test_adapter {
  'nvim-neotest/neotest-python',
  module = 'neotest-python',
  opts = { dap = { justMyCode = false } },
}

return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { lang_name },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if vim.fs.root(fname, 'codeterraform-workspace.json') then return end
    on_dir(vim.fs.root(fname, {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      '.git',
    }))
  end,
  root_markers = {
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        useLibraryCodeForTypes = true,
        typeCheckingMode = 'strict',
      },
    },
  },
}
