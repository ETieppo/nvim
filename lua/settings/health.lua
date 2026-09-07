vim.api.nvim_create_user_command(
  'NvimDeps',
  function() require('utils.os').install(require 'utils.nvim_deps') end,
  { desc = 'Install minimal needed dependencies X_X' }
)

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local missing = require('utils.os').missing(require 'utils.nvim_deps')
    if #missing == 0 then return end
    local names = vim.tbl_map(function(d) return d.name end, missing)
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

vim.api.nvim_create_user_command(
  'LangInstall',
  function(opts) require('utils.lang_deps').ensure_lang_deps(opts.args) end,
  { nargs = 1 }
)
