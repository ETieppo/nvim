local lsp = require 'core.lsp.registry'
local lang_name = require('utils.helpers').get_this_directory_name()

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
