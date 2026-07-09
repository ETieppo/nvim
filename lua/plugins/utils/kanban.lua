local function act(name, desc)
  return {
    callback = function(...) require('super-kanban.actions')[name](...) end,
    desc = desc,
  }
end

local kanban_file_name = 'kanban.md'
return {
  'hasansujon786/super-kanban.nvim',
  dependencies = {
    'folke/snacks.nvim',
    'nvim-orgmode/orgmode',
  },

  cmd = 'SuperKanban',
  keys = {
    {
      '<leader>ko',
      '<cmd>SuperKanban open ' .. kanban_file_name .. '<cr>',
      desc = '[K]anban [O]pen',
    },
    {
      '<leader>kfn',
      '<cmd>SuperKanban create ' .. kanban_file_name .. '<cr>',
      desc = '[K]anban [F]ile [N]ew',
    },
  },

  opts = {
    markdown = {
      notes_dir = './tasks/',
      list_heading = 'h2',
      default_template = {
        '## Backlog\n',
        '## Todo\n',
        '## Work in progress\n',
        '## Completed\n',
      },
    },
    board = { zindex = 100 },
    list = { zindex = 101 },
    card = { zindex = 102 },
    note_popup = { zindex = 103 },
    date_picker = { zindex = 104 },

    mappings = {
      -- ── New ─────────────────────────────────────────────
      ['<leader>knn'] = act(
        'open_note',
        '[K]anban [N]ote [N]ew (open card note)'
      ),
      ['<leader>kcn'] = act(
        'create_card_after',
        '[K]anban [C]ard [N]ew (after)'
      ),
      ['<leader>kCn'] = act(
        'create_card_before',
        '[K]anban [C]ard [N]ew (before)'
      ),
      ['<leader>kln'] = act(
        'create_list_at_end',
        '[K]anban [L]ist [N]ew (end)'
      ),
      ['<leader>kLn'] = act(
        'create_list_at_begin',
        '[K]anban [L]ist [N]ew (start)'
      ),

      -- ── Card ─------------───────────────────────────────
      ['<leader>kcd'] = act('delete_card', '[K]anban [C]ard [D]elete'),
      ['<leader>kct'] = act(
        'toggle_complete',
        '[K]anban [C]ard [T]oggle complete'
      ),
      ['<leader>kca'] = act('archive_card', '[K]anban [C]ard [A]rchive'),
      ['<leader>kcs'] = act('search_card', '[K]anban [C]ard [S]earch'),

      -- ── Date ---------------------------─────────────────
      ['<leader>kdp'] = act('pick_date', '[K]anban [D]ate [P]ick'),
      ['<leader>kdr'] = {
        callback = function() vim.cmd 'SuperKanban card remove_date' end,
        desc = '[K]anban [D]ate [R]emove',
      },

      -- ── List  ------------───────────────────────────────
      ['<leader>kld'] = act('delete_list', '[K]anban [L]ist [D]elete'),
      ['<leader>klr'] = act('rename_list', '[K]anban [L]ist [R]ename'),
      ['<leader>kls'] = act(
        'sort_by_due_ascending',
        '[K]anban [L]ist [S]ort (ascending)'
      ),
      ['<leader>klS'] = act(
        'sort_by_due_descending',
        '[K]anban [L]ist [S]ort (descending)'
      ),

      -- ── Misc ────────────────────────────────────────────
      ['<leader>k?'] = act('help', '[K]anban help'),
    },
  },
}
