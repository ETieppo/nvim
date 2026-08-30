vim.api.nvim_create_user_command(
  'Deps',
  function() require('utils.deps').install() end,
  { desc = 'Install minimal needed dependencies X_X' }
)

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local missing = require('utils.deps').missing()
    if #missing == 0 then return end
    local names = vim.tbl_map(function(d) return d.name end, missing)
    vim.schedule(
      function()
        vim.notify(
          'Some deps could not be find ()_()\n'
            .. table.concat(names, ',\n')
            .. '\nRun :Deps to install ;)',
          vim.log.levels.WARN,
          { title = 'Neovim setup' }
        )
      end
    )
  end,
})
