local lang_mod = require 'utils.lang'
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
      cmd = 'black',
      os = {
        macos = 'brew install black',
        archlinux = 'sudo pacman -S python-black',
        windows = 'pip install black',
      },
    },
  },
}

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'black',
}

lang_mod.record_test_adapter {
  'nvim-neotest/neotest-python',
  module = 'neotest-python',
  opts = { dap = { justMyCode = false } },
}

return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { lang_name },
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
