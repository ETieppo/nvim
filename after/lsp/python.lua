local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_lang_deps {
  short = 'py',
  deps = {
    { cmd = 'python3', install_command = 'python' },
    {
      cmd = 'pyright-langserver',
      os = { unix = 'pyright' },
    },
    { cmd = 'ruff' },
  },
}

lang_mod.record_fmt {
  formatter = 'ruff_format',
}

lang_mod.record_test_adapter {
  'nvim-neotest/neotest-python',
  module = 'neotest-python',
  opts = { dap = { justMyCode = false } },
}

lang_mod.record_dap_adapter {
  name = 'python',
  cmd = 'python3',
  check = function(path)
    local probe = { path, '-c', 'import debugpy' }
    return vim.system(probe, { text = true }):wait().code == 0
  end,
  build = function(path)
    return {
      type = 'executable',
      command = path,
      args = { '-m', 'debugpy.adapter' },
    }
  end,
}

lang_mod.record_dap {
  adapter = 'python',
  configurations = {
    {
      name = 'Launch file',
      type = 'python',
      request = 'launch',
      program = '${file}',
      cwd = '${workspaceFolder}',
      console = 'integratedTerminal',
      justMyCode = false,
    },
  },
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
