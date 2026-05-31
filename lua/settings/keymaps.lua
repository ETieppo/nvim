-- =============================================================================
-- keymaps.lua  —  todos os keymaps "de verdade" ficam aqui.
--
-- NÃO ficam aqui (são gatilhos de lazy-loading, vivem na spec do plugin):
--   • DAP        (core/dap/dap.lua)
--   • Trouble    (utils/trouble.lua)
--   • DevDocs    (utils/devdocs.lua)
--   • GitGraph   (utils/gitgraph.lua)
--   • Neo-tree \ (utils/neo-tree.lua)
--   • <leader>ff (core/autoformat.lua)
--   • Rust K / <leader>r* (lsp/rust_lsp.lua — específicos do rustaceanvim)
--
-- IMPORTANTE: este arquivo carrega ANTES do lazy.nvim. Por isso qualquer
-- require de plugin (telescope, gitsigns) é adiado dentro de uma função.
-- =============================================================================

-- Leaders ---------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Desabilita setas — pensa com hjkl ------------------------------------------
vim.keymap.set('n', '<left>', '<nop>')
vim.keymap.set('n', '<right>', '<nop>')
vim.keymap.set('n', '<up>', '<nop>')
vim.keymap.set('n', '<down>', '<nop>')

-- Mover linhas (Alt + j/k) ----------------------------------------------------
vim.keymap.set('n', '<D-k>', ':m .-2<CR>==', { silent = true, desc = 'Move line up' })
vim.keymap.set('n', '<D-j>', ':m .+1<CR>==', { silent = true, desc = 'Move line down' })
vim.keymap.set('i', '<D-k>', '<Esc>:m .-2<CR>==gi', { silent = true })
vim.keymap.set('i', '<D-j>', '<Esc>:m .+1<CR>==gi', { silent = true })
vim.keymap.set('v', '<D-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move selection up' })
vim.keymap.set('v', '<D-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move selection down' })

-- Diversos --------------------------------------------------------------------
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>l', '<cmd>Lazy<CR>', { desc = 'Open [L]azy' })
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Navegação entre janelas -----------------------------------------------------
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus upper window' })

-- Buffers ---------------------------------------------------------------------
vim.keymap.set('n', '<D-M-Right>', '<cmd>BufferLineCycleNext<CR>', { silent = true, desc = 'Next buffer' })
vim.keymap.set('n', '<D-M-Left>', '<cmd>BufferLineCyclePrev<CR>', { silent = true, desc = 'Previous buffer' })

vim.keymap.set('n', '<leader>bd', function()
  local cur = vim.api.nvim_get_current_buf()
  local next_buf = nil
  local alt = vim.fn.bufnr '#'
  if alt > 0 and alt ~= cur and vim.fn.buflisted(alt) == 1 then next_buf = alt end
  if not next_buf then
    for _, info in ipairs(vim.fn.getbufinfo { buflisted = 1 }) do
      if info.bufnr ~= cur then
        next_buf = info.bufnr
        break
      end
    end
  end
  if next_buf then vim.api.nvim_set_current_buf(next_buf) end
  vim.cmd('bdelete ' .. cur)
end, { desc = '[B]uffer [D]elete' })

-- Operações de arquivo --------------------------------------------------------
vim.keymap.set('n', '<leader>fn', function()
  local dir = vim.fn.expand '%:p:h'
  local path = vim.fn.input('New file: ', dir .. '/', 'file')
  if path == '' then return end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.cmd('edit ' .. path)
end, { desc = '[F]ile [N]ew' })

vim.keymap.set('n', '<leader>fd', function()
  local file = vim.fn.expand '%:p'
  if vim.fn.confirm('Delete file?\n' .. file, '&Yes\n&No', 2) == 1 then
    vim.fn.delete(file)
    vim.cmd 'bdelete!'
    print('Deleted ' .. file)
  end
end, { desc = '[F]ile [D]elete current' })

vim.keymap.set('n', '<leader>fr', function()
  local old = vim.fn.expand '%:p'
  local dir = vim.fn.expand '%:p:h'
  local ext = vim.fn.expand '%:e'
  local default = dir .. '/.' .. ext
  local move = #ext + 1
  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move), 'n', false) end)
  local new = vim.fn.input('Rename to: ', default, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
  vim.fn.rename(old, new)
  vim.cmd('edit ' .. new)
  vim.cmd 'bdelete! #'
end, { desc = '[F]ile [R]ename' })

vim.keymap.set('n', '<leader>fm', function()
  local old = vim.fn.expand '%:p'
  local name = vim.fn.expand '%:t'
  local move = #name
  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move), 'n', false) end)
  local new = vim.fn.input('Move to: ', old, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
  vim.fn.rename(old, new)
  vim.cmd('edit ' .. vim.fn.fnameescape(new))
  vim.cmd 'bdelete! #'
end, { desc = '[F]ile [M]ove' })

vim.keymap.set('n', '<leader>fc', function()
  local old = vim.fn.expand '%:p'
  local name = vim.fn.expand '%:t'
  local move_cursor = #name
  vim.schedule(function() vim.api.nvim_feedkeys(string.rep(vim.api.nvim_replace_termcodes('<Left>', true, false, true), move_cursor), 'n', false) end)
  local new = vim.fn.input('Copy to: ', old, 'file')
  if new == '' or new == old then return end
  vim.fn.mkdir(vim.fn.fnamemodify(new, ':h'), 'p')
  local success = vim.loop.fs_copyfile(old, new)
  if success then
    vim.cmd('edit ' .. vim.fn.fnameescape(new))
  else
    print '\nError at file clone.'
  end
end, { desc = '[F]ile [C]opy' })

-- Config (edição da própria config do nvim) -----------------------------------
vim.keymap.set('n', '<leader>cn', function()
  local config_lua_path = vim.fn.stdpath 'config' .. '/lua/'
  local path = vim.fn.input('New Lua config: ', config_lua_path, 'file')
  if path == '' then return end
  if not path:match '%.lua$' then path = path .. '.lua' end
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.cmd('edit ' .. path)
end, { desc = '[C]onfig [N]ew' })

vim.keymap.set('n', '<leader>cs', function()
  require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[C]onfig [S]earch files' })

vim.keymap.set('n', '<leader>cg', function()
  require('telescope.builtin').live_grep {
    cwd = vim.fn.stdpath 'config',
    prompt_title = 'Live grep in neovim config',
  }
end, { desc = '[C]onfig [G]rep' })

-- Telescope (busca) -----------------------------------------------------------
vim.keymap.set('n', '<leader>sh', function() require('telescope.builtin').help_tags() end, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', function() require('telescope.builtin').keymaps() end, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ss', function() require('telescope.builtin').builtin() end, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sg', function() require('telescope.builtin').live_grep() end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', function() require('telescope.builtin').diagnostics() end, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', function() require('telescope.builtin').resume() end, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', function() require('telescope.builtin').oldfiles() end, { desc = '[S]earch Recent Files' })
vim.keymap.set('n', '<leader>sc', function() require('telescope.builtin').commands() end, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader>sf', function() require('telescope.builtin').buffers() end, { desc = '[S]earch open buffers' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', function() require('telescope.builtin').grep_string() end, { desc = '[S]earch current [W]ord' })

vim.keymap.set('n', '<leader><leader>', function()
  require('telescope.builtin').find_files { hidden = true, no_ignore = true }
end, { desc = '[S]earch Files' })

vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Neovide ---------------------------------------------------------------------
if vim.g.neovide then
  vim.keymap.set('n', '<D-n>', function()
    vim.fn.jobstart('neovide --new-window --reuse-instance --chdir ' .. vim.fn.getcwd(), { detach = true })
  end, { desc = 'Nova janela Neovide no cwd' })
  vim.keymap.set('v', '<D-c>', '"+y')
  vim.keymap.set('n', '<D-v>', '"+P')
  vim.keymap.set('v', '<D-v>', '"+P')
  vim.keymap.set('i', '<D-v>', '<C-r>+')
  vim.keymap.set('c', '<D-v>', '<C-r>+')
  vim.keymap.set('t', '<D-v>', [[<C-\><C-n>"+pi]])
  vim.keymap.set('n', '<D-a>', 'ggVG')
end

-- =============================================================================
-- LSP  —  keymaps buffer-local, ligados só quando um servidor anexa ao buffer.
-- (Substitui os blocos LspAttach que estavam em nvim-lspconfig.lua e telescope.lua)
-- Prefixo gr* alinhado com os defaults nativos do Neovim 0.11+.
-- =============================================================================
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf
    local tb = function() return require 'telescope.builtin' end
    local map = function(keys, func, desc, mode)
      vim.keymap.set(mode or 'n', keys, func, { buffer = buf, desc = 'LSP: ' .. desc })
    end

    -- Navegação (references / impl / type / symbols via Telescope)
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, 'Goto [D]eclaration')
    map('grr', function() tb().lsp_references() end, 'Goto [R]eferences')
    map('gri', function() tb().lsp_implementations() end, 'Goto [I]mplementation')
    map('grt', function() tb().lsp_type_definitions() end, 'Goto [T]ype Definition')
    map('gO', function() tb().lsp_document_symbols() end, 'Document Symbols')
    map('gW', function() tb().lsp_dynamic_workspace_symbols() end, 'Workspace Symbols')

    -- Goto Definition com dedup: pula direto se houver 1 resultado, senão Telescope
    map('gd', function()
      vim.lsp.buf.definition {
        on_list = function(options)
          local seen, unique = {}, {}
          for _, item in ipairs(options.items) do
            local key = (item.filename or '') .. ':' .. (item.lnum or 0) .. ':' .. (item.col or 0)
            if not seen[key] then
              seen[key] = true
              table.insert(unique, item)
            end
          end
          options.items = unique
          if #unique == 1 then
            vim.cmd('e ' .. vim.fn.fnameescape(unique[1].filename))
            vim.api.nvim_win_set_cursor(0, { unique[1].lnum, (unique[1].col or 1) - 1 })
            vim.cmd 'normal! zz'
          elseif #unique > 1 then
            vim.fn.setqflist({}, ' ', options)
            require('telescope.builtin').quickfix()
          end
        end,
      }
    end, 'Goto Definition')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Toggle inlay hints (se o servidor suportar)
    if client and client:supports_method('textDocument/inlayHint', buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = buf })
      end, '[T]oggle Inlay [H]ints')
    end

    -- Realçar referências ao parar o cursor (comportamento, não keymap)
    if client and client:supports_method('textDocument/documentHighlight', buf) then
      local hl = vim.api.nvim_create_augroup('user-lsp-highlight', { clear = false })
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
        group = vim.api.nvim_create_augroup('user-lsp-detach', { clear = true }),
        callback = function(e2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'user-lsp-highlight', buffer = e2.buf }
        end,
      })
    end
  end,
})

-- =============================================================================
-- Gitsigns  —  mapas globais com require adiado.
-- (Substitui o on_attach que estava em core/gitsigns.lua)
-- =============================================================================
local gs = function() return require 'gitsigns' end

vim.keymap.set('n', ']c', function()
  if vim.wo.diff then
    vim.cmd.normal { ']c', bang = true }
  else
    gs().nav_hunk 'next'
  end
end, { desc = 'Next git [c]hange' })

vim.keymap.set('n', '[c', function()
  if vim.wo.diff then
    vim.cmd.normal { '[c', bang = true }
  else
    gs().nav_hunk 'prev'
  end
end, { desc = 'Prev git [c]hange' })

vim.keymap.set('v', '<leader>hs', function() gs().stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [s]tage hunk' })
vim.keymap.set('v', '<leader>hr', function() gs().reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'git [r]eset hunk' })
vim.keymap.set('n', '<leader>hs', function() gs().stage_hunk() end, { desc = 'git [s]tage hunk' })
vim.keymap.set('n', '<leader>hr', function() gs().reset_hunk() end, { desc = 'git [r]eset hunk' })
vim.keymap.set('n', '<leader>hS', function() gs().stage_buffer() end, { desc = 'git [S]tage buffer' })
vim.keymap.set('n', '<leader>hu', function() gs().stage_hunk() end, { desc = 'git [u]ndo stage hunk' })
vim.keymap.set('n', '<leader>hR', function() gs().reset_buffer() end, { desc = 'git [R]eset buffer' })
vim.keymap.set('n', '<leader>hp', function() gs().preview_hunk() end, { desc = 'git [p]review hunk' })
vim.keymap.set('n', '<leader>hb', function() gs().blame_line() end, { desc = 'git [b]lame line' })
vim.keymap.set('n', '<leader>hd', function() gs().diffthis() end, { desc = 'git [d]iff against index' })
vim.keymap.set('n', '<leader>hD', function() gs().diffthis '@' end, { desc = 'git [D]iff against last commit' })
vim.keymap.set('n', '<leader>tb', function() gs().toggle_current_line_blame() end, { desc = '[T]oggle git [b]lame line' })
vim.keymap.set('n', '<leader>tD', function() gs().preview_hunk_inline() end, { desc = '[T]oggle git show [D]eleted' })
