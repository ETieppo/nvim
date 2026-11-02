vim.diagnostic.config {
  virtual_text = {
    enabled = true,
    prefix = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.ERROR then
        return '🭰× '
      elseif diagnostic.severity == vim.diagnostic.severity.WARN then
        return '🭰▲ '
      else
        return '🭰• '
      end
    end,
    suffix = '🭵',
  },
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ×',
      [vim.diagnostic.severity.WARN] = ' ▲',
      [vim.diagnostic.severity.HINT] = ' •',
      [vim.diagnostic.severity.INFO] = ' •',
    },
  },
}

return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 1000,
  config = function()
    require('tiny-inline-diagnostic').setup()
    vim.diagnostic.config { virtual_text = false }
  end,
}
