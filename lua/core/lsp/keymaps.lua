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
          ---@type table<string, boolean>
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
