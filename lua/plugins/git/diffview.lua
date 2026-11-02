return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  keys = {
    {
      '<leader>gt',
      '<cmd>DiffviewOpen<cr>',
      desc = '[G]it [T]ree',
    },
    {
      '<leader>ghf',
      '<cmd>DiffviewFileHistory %<cr>',
      desc = '[G]it [H]istory [F]ile',
    },
    {
      '<leader>ghr',
      '<cmd>DiffviewFileHistory<cr>',
      desc = '[G]it [H]istory [R]epo',
    },
    {
      '<leader>gbc',
      function()
        vim.ui.input({ prompt = 'Compare with (ex: main): ' }, function(base)
          if base and base:match '%S' then
            vim.cmd('DiffviewOpen ' .. base .. '..HEAD')
          end
        end)
      end,
      desc = '[G]it [B]ranch [C]ompare',
    },
  },
  opts = {
    file_panel = { listing_style = 'tree' },
  },
}
