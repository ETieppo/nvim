vim.api.nvim_create_user_command(
  'NvimDeps',
  function() require('utils.deps_mod').install(require 'utils.nvim_deps') end,
  { desc = 'Install minimal needed dependencies X_X' }
)

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local missing =
      require('utils.deps_mod').find_missing(require 'utils.nvim_deps')
    if #missing == 0 then return end

    local names = vim.tbl_map(function(dep) return dep.cmd end, missing)
    vim.schedule(
      function()
        vim.notify(
          'Some deps could not be find ()_()\n'
            .. table.concat(names, ',\n')
            .. '\nRun :NvimDeps to install ;)',
          vim.log.levels.WARN,
          { title = 'Neovim setup' }
        )
      end
    )
  end,
})
