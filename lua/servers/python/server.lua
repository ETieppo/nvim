local deps = require 'core.lang.registry'
local lsp = require 'core.lsp.registry'
local fmt = require 'core.formatter.registry'
local dap = require 'core.dap.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

deps.record_toolchain {
  short = 'py',
  deps = { { cmd = 'python3', install_command = 'python' } },
}

fmt.record_fmt {
  formatter = 'ruff_format',
  deps = { { cmd = 'ruff' } },
}

dap.record_dap {
  adapter = {
    name = 'python',
    cmd = 'python3',
    availability_check_args = { '-c', 'import debugpy' },
    args = { '-m', 'debugpy.adapter' },
    deps = {
      {
        cmd = 'debugpy',
        check_cmd = 'python3 -c "import debugpy"',
        install_command = 'python3 -m pip install --user --break-system-packages debugpy',
        os = {
          linux = 'python-debugpy',
          windows = 'python -m pip install debugpy',
        },
      },
    },
  },
  configurations = {
    {
      program = '${file}',
      console = 'integratedTerminal',
      justMyCode = false,
    },
  },
}

lsp.record_lsp {
  deps = { { os = { unix = 'pyright' } } },
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { lang_name },
  root_dir = function(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local codeterraform_config = vim.lsp.config.codeterraform
    local codeterraform_markers = codeterraform_config
        and codeterraform_config.root_markers
      or {}
    if vim.fs.root(fname, codeterraform_markers) then return end
    on_dir(vim.fs.root(fname, {
      'pyproject.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      '.git',
    }))
  end,
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
