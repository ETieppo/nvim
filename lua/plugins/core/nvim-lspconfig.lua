return {
  'neovim/nvim-lspconfig',
  dependencies = {
    {
      'mason-org/mason.nvim',
      opts = {},
    },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    { 'j-hui/fidget.nvim', opts = {} },
    'saghen/blink.cmp',
  },

  config = function()
    local util = require 'lspconfig.util'

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or 'n'
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
        map('gr', require('telescope.builtin').lsp_references, 'Goto References')
        map('gi', require('telescope.builtin').lsp_implementations, 'Goto Impl')

        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client:supports_method('textDocument/documentHighlight', event.buf) then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })

          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        if client and client:supports_method('textDocument/inlayHint', event.buf) then
          map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    local servers = {
      ts_ls = {},
      stylua = {},
      taplo = {},
      marksman = {},
      cssls = {},

      clangd = {
        cmd = {
          'clangd',
          '--header-insertion-decorators=0',
          '--background-index',
          '--clang-tidy',
          '--clang-tidy-checks=-llvm-header-guard,-llvm-copyright',
        },
      },

      rust_analyzer = {
        cmd = { '/Users/tieppo/.cargo/bin/rust-analyzer' },
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = true,
            check = {
              command = 'clippy',
              workspace = true,
            },
            cargo = {
              allTargets = true,
              features = 'all',
            },
            procMacro = {
              enable = true,
              attributes = {
                enable = true,
              },
            },
          },
        },
      },

      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim' },
              disable = { 'missing-fields' },
            },
            hint = {
              enable = true,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      },
    }

    local ensure_installed = vim.tbl_keys(servers)

    require('mason-tool-installer').setup {
      ensure_installed = ensure_installed,
    }

    for name, server in pairs(servers) do
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end
  end,
}
