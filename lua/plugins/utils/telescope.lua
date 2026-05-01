return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function() return vim.fn.executable 'make' == 1 end,
    },
  },
  enabled = true,
  event = 'VimEnter',
  config = function()
    require('telescope').setup {
      defaults = {
        file_ignore_patterns = {
          'node_modules/',
          '.git/',
          'dist/',
          'target/',
          'Cargo.lock',
          '.DS_Store',
          'bin/',
          'build/',
          '.gradle/',
          '.metadata/',
          'gradle/',
          'jdt.ls-java-project/',
          '.godot/',
          '.angular'
        },
      },
      extensions = {
        ['ui-select'] = { require('telescope.themes').get_dropdown() },
      },
    }

    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader><leader>', function() builtin.find_files { hidden = true, no_ignore = true } end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
    vim.keymap.set('n', '<leader>sf', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
      callback = function(event)
        local buf = event.buf

        local lsp_opts = { file_ignore_patterns = {} }
        vim.keymap.set('n', 'grr', function() builtin.lsp_references(lsp_opts) end, { buffer = buf, desc = '[G]oto [R]eferences' })
        vim.keymap.set('n', 'gri', function() builtin.lsp_implementations(lsp_opts) end, { buffer = buf, desc = '[G]oto [I]mplementation' })
        vim.keymap.set('n', 'gd', function() builtin.lsp_definitions(lsp_opts) end, { buffer = buf, desc = '[G]oto [D]efinition' })
        vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
        vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
        vim.keymap.set('n', 'grt', function() builtin.lsp_type_definitions(lsp_opts) end, { buffer = buf, desc = '[G]oto [T]ype Definition' })
      end,
    })

    vim.keymap.set(
      'n',
      '<leader>/',
      function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end,
      { desc = '[/] Fuzzily search in current buffer' }
    )

    vim.keymap.set(
      'n',
      '<leader>s/',
      function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end,
      { desc = '[S]earch [/] in Open Files' }
    )

    vim.keymap.set('n', '<leader>cs', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[C]onfig [S]earch' })
  end,
}
