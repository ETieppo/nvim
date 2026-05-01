return {
  'WhoIsSethDaniel/mason-tool-installer.nvim',
  dependencies = { 'williamboman/mason.nvim' },
  config = function()
    require('mason').setup()
    require('mason-tool-installer').setup {
      ensure_installed = {
        --- lsp servers
        'typescript-language-server',
        'angular-language-server',
        'emmet-language-server',
        --- linters
        'selene',
        'markdownlint-cli2',
        'cpplint',
        --- formatters
        'stylua',
      },
    }

    local mason_packages = vim.fn.stdpath 'data' .. '/mason/packages'
    local angular_pkg = mason_packages .. '/angular-language-server/node_modules/@angular/language-server'
    local ts_lib = mason_packages .. '/angular-language-server/node_modules/typescript/lib'

    vim.filetype.add {
      pattern = {
        ['.*%.component%.html'] = 'htmlangular',
      },
    }


    vim.lsp.config('emmet_language_server', {
      cmd = { 'emmet-language-server', '--stdio' },
      filetypes = {
        'html',
        'htmlangular',
        'css',
        'scss',
        'sass',
        'less',
        'typescriptreact',
        'javascriptreact',
      },
      root_markers = { '.git', 'package.json' },
      init_options = {
        includeLanguages = {
          htmlangular = 'html',
        },
      },
    })

    vim.lsp.config('angularls', {
      cmd = {
        'ngserver',
        '--stdio',
        '--tsProbeLocations', ts_lib,
        '--ngProbeLocations', angular_pkg,
      },
      filetypes = { 'html', 'htmlangular' },
      root_markers = { 'angular.json' },
    })

    vim.lsp.config('ts_ls', {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
      },
      root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
    })

    vim.lsp.enable { 'ts_ls', 'angularls', 'emmet_language_server' }
  end,
}
