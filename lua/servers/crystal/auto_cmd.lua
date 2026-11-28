local lang_name = require('utils.helpers').get_this_directory_name()

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup(
    'crystal-commentstring',
    { clear = true }
  ),
  pattern = lang_name,
  callback = function(args) vim.bo[args.buf].commentstring = '# %s' end,
})
