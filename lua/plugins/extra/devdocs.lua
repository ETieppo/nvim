return {
  'maskudo/devdocs.nvim',
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>dds',
      mode = 'n',
      '<cmd>DevDocs get<cr>',
      desc = '[D]ev[D]ocs [S]earch',
    },
    {
      '<leader>ddi',
      mode = 'n',
      '<cmd>DevDocs install<cr>',
      desc = '[D]ev[D]ocs [I]nstall',
    },
    {
      '<leader>ddd',
      mode = 'n',
      '<cmd>DevDocs delete<cr>',
      desc = '[D]ev[D]ocs [D]elete',
    },
    {
      '<leader>ddg',
      mode = 'n',
      function()
        local devdocs = require 'devdocs'
        local installed = devdocs.GetInstalledDocs()
        vim.ui.select(
          installed,
          { prompt = 'Grep em qual doc?' },
          function(selected)
            if not selected then return end
            local doc_dir = devdocs.GetDocDir(selected)
            require('telescope.builtin').live_grep { cwd = doc_dir }
          end
        )
      end,
      desc = '[D]ev [D]ocs [G]rep',
    },
  },
  opts = function()
    return {
      ensure_installed = vim.list_extend(
        { 'git', 'http' },
        require('utils.lang_mod').get_docs()
      ),
    }
  end,
}
