local lang_deps = require 'deps.language'

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('lang-missing-deps', { clear = true }),
  callback = function(args)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        lang_deps.warn_missing_lang_deps(args.match, args.buf)
      end
    end)
  end,
})
