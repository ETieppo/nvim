local ArrowKeyEnum = require 'utils.enums.arrow_key_enum'
local file = require 'buffer.file'
local helpers = require 'utils.helpers'
local os_mod = require 'utils.os_mod'
local ripgrep = require 'utils.ripgrep'

-- Disable arrows -------------------------------------------------------------
for _, mode in ipairs { 'n', 'i', 'v' } do
  for _, arrow_key in pairs(ArrowKeyEnum) do
    vim.keymap.set(mode, arrow_key, '<nop>')
  end
end

-- Several --------------------------------------------------------------------
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set(
  'n',
  '<leader>q',
  vim.diagnostic.setloclist,
  { desc = 'Diagnostic [Q]uickfix list' }
)

vim.keymap.set('n', '<leader>dbt', function()
  local ok, dbui = pcall(require, 'settings.dbui')
  if not ok then
    vim.notify("Set 'Max' profile to use dbui", vim.log.levels.WARN)
    return
  end

  dbui.toggle()
end, { desc = '[D]ata[B]ase [T]oggle' })

vim.keymap.set(
  'n',
  '<leader>dbcn',
  '<cmd>DBUIAddConnection<CR>',
  { desc = '[D]ata[B]ase [C]onnection [N]ew' }
)
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = '[L]azy [O]pen' })
vim.keymap.set(
  't',
  '<Esc><Esc>',
  '<C-\\><C-n>',
  { desc = 'Exit terminal mode' }
)

-- Line Operations -----------------------------------------------------------
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-j>',
  ':m .+1<CR>==',
  { desc = 'Move line down' }
)
helpers.set_alt_and_cmd_keymap(
  'n',
  '<M-k>',
  ':m .-2<CR>==',
  { desc = 'Move line up' }
)
helpers.set_alt_and_cmd_keymap(
  'x',
  '<M-j>',
  ":silent! m '>+1<CR>gv=gv",
  { desc = 'Move selection down' }
)
helpers.set_alt_and_cmd_keymap(
  'x',
  '<M-k>',
  ":silent! m '<-2<CR>gv=gv",
  { desc = 'Move selection up' }
)

-- Neovim Config Operations ---------------------------------------------------
vim.keymap.set('n', '<leader>cn', function()
  local config_lua_path = os_mod.normalize_os_path(vim.fn.stdpath 'config')
    .. '/'
  file.prompt_path('New Lua config: ', config_lua_path, nil, function(path)
    if path == '' then return end
    if not path:match '%.lua$' then path = path .. '.lua' end
    file.create_file(path)
  end)
end, { desc = '[C]onfig [N]ew' })

vim.keymap.set(
  'n',
  '<leader>cs',
  function()
    require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
  end,
  { desc = '[C]onfig [S]earch files' }
)

vim.keymap.set(
  'n',
  '<leader>cg',
  function()
    require('telescope.builtin').live_grep {
      cwd = vim.fn.stdpath 'config',
      prompt_title = 'Live grep in neovim config',
    }
  end,
  { desc = '[C]onfig [G]rep' }
)

-- Telescope Operations -----------------------------------------------------------
vim.keymap.set(
  'n',
  '<leader>sh',
  function() require('telescope.builtin').help_tags() end,
  { desc = '[S]earch [H]elp' }
)
vim.keymap.set(
  'n',
  '<leader>sk',
  function() require('telescope.builtin').keymaps() end,
  { desc = '[S]earch [K]eymaps' }
)
vim.keymap.set(
  'n',
  '<leader>ss',
  function() require('telescope.builtin').builtin() end,
  { desc = '[S]earch [S]elect Telescope' }
)
vim.keymap.set(
  'n',
  '<leader>sg',
  function() require('telescope.builtin').live_grep() end,
  { desc = '[S]earch by [G]rep' }
)
vim.keymap.set(
  'n',
  '<leader>sd',
  function() require('telescope.builtin').diagnostics() end,
  { desc = '[S]earch [D]iagnostics' }
)
vim.keymap.set(
  'n',
  '<leader>sc',
  function() require('telescope.builtin').commands() end,
  { desc = '[S]earch [C]ommands' }
)
vim.keymap.set(
  { 'n', 'v' },
  '<leader>sw',
  function() require('telescope.builtin').grep_string() end,
  { desc = '[S]earch current [W]ord' }
)
vim.keymap.set(
  'n',
  '<leader><leader>',
  function() require('telescope.builtin').find_files() end,
  { desc = 'Search Files' }
)

vim.keymap.set(
  'n',
  '<leader>a',
  function()
    require('telescope.builtin').find_files {
      prompt_title = 'Find All Files',
      find_command = ripgrep.build_command(
        { '--files', '--color=never', '--no-ignore' },
        { '.git/' }
      ),
    }
  end,
  { desc = '[A]ll Files' }
)

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    require('telescope.builtin').current_buffer_fuzzy_find(
      require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      }
    )
  end,
  { desc = '[/] Fuzzily search in current buffer' }
)

vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    require('telescope.builtin').live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- LSP Operations ------------------------------------------------------------
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local tb = function() return require 'telescope.builtin' end
    local set_lsp_keymap = function(keys, func, desc, mode)
      vim.keymap.set(
        mode or 'n',
        keys,
        func,
        { buffer = buf, desc = 'LSP: ' .. desc }
      )
    end

    set_lsp_keymap('grD', vim.lsp.buf.declaration, 'Goto [D]eclaration')
    set_lsp_keymap(
      'grr',
      function() tb().lsp_references() end,
      'Goto [R]eferences'
    )
    set_lsp_keymap(
      'gri',
      function() tb().lsp_implementations() end,
      'Goto [I]mplementation'
    )
    set_lsp_keymap(
      'grt',
      function() tb().lsp_type_definitions() end,
      'Goto [T]ype Definition'
    )
    set_lsp_keymap(
      'gO',
      function() tb().lsp_document_symbols() end,
      'Document Symbols'
    )
    set_lsp_keymap(
      'gW',
      function() tb().lsp_dynamic_workspace_symbols() end,
      'Workspace Symbols'
    )

    set_lsp_keymap('gd', function()
      vim.lsp.buf.definition {
        on_list = function(options)
          local seen, unique = {}, {}
          for _, item in ipairs(options.items) do
            local key = (item.filename or '')
              .. ':'
              .. (item.lnum or 0)
              .. ':'
              .. (item.col or 0)
            if not seen[key] then
              seen[key] = true
              table.insert(unique, item)
            end
          end
          options.items = unique
          if #unique == 1 then
            vim.cmd('e ' .. vim.fn.fnameescape(unique[1].filename))
            vim.api.nvim_win_set_cursor(
              0,
              { unique[1].lnum, (unique[1].col or 1) - 1 }
            )
            vim.cmd 'normal! zz'
          elseif #unique > 1 then
            vim.fn.setqflist({}, ' ', options)
            require('telescope.builtin').quickfix()
          end
        end,
      }
    end, 'Goto Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if
      client and client:supports_method('textDocument/documentHighlight', buf)
    then
      local hl =
        vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = buf,
        group = hl,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = buf,
        group = hl,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup(
          'user-lsp-detach',
          { clear = true }
        ),
        callback = function(e2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'user-lsp-highlight',
            buffer = e2.buf,
          }
        end,
      })
    end
  end,
})

-- NeoTest Operations -----------------------------------------------------
vim.keymap.set(
  'n',
  '<leader>tt',
  function() require('neotest').run.run() end,
  { desc = '[T]est [T]his' }
)
vim.keymap.set(
  'n',
  '<leader>tf',
  function() require('neotest').run.run(vim.fn.expand '%') end,
  { desc = '[T]est [F]ile' }
)
vim.keymap.set(
  'n',
  '<leader>td',
  function() require('neotest').run.run { suite = false, strategy = 'dap' } end,
  { desc = '[T]est [D]ebug' }
)
vim.keymap.set(
  'n',
  '<leader>tr',
  function() require('neotest').summary.toggle() end,
  { desc = '[T]est [R]eport' }
)
vim.keymap.set(
  'n',
  '<leader>to',
  function() require('neotest').output.open { enter = true } end,
  { desc = '[T]est [O]utput' }
)
vim.keymap.set(
  'n',
  '<leader>ts',
  function() require('neotest').run.stop() end,
  { desc = '[T]est [S]top' }
)
vim.keymap.set(
  'n',
  '<leader>ta',
  function() require('neotest').run.run { suite = true } end,
  { desc = '[T]est [A]ll' }
)
