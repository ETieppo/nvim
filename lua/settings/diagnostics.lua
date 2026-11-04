local diagnostic_prefix = '🭰'
local diagnostic_suffix = '🭵'

local function wrap_virtual_diagnostic(diagnostic)
  local win = vim.fn.bufwinid(diagnostic.bufnr)
  if win == -1 then win = vim.api.nvim_get_current_win() end

  local textoff = vim.fn.getwininfo(win)[1].textoff
  local width =
    math.max(vim.api.nvim_win_get_width(win) - textoff - diagnostic.col - 6, 20)

  local lines = {}
  for _, paragraph in ipairs(vim.split(diagnostic.message, '\n')) do
    local line = diagnostic_prefix
    for word in paragraph:gmatch '%S+' do
      if line ~= '' and vim.fn.strdisplaywidth(line .. ' ' .. word) > width then
        table.insert(lines, line)
        line = word
      else
        line = line == '' and word or (line .. ' ' .. word)
      end
    end
    table.insert(lines, line .. diagnostic_suffix)
  end

  return table.concat(lines, '\n')
end

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = {
    format = wrap_virtual_diagnostic,
  },
  severity_sort = true,
  underline = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_prefix,
      [vim.diagnostic.severity.WARN] = diagnostic_prefix,
      [vim.diagnostic.severity.HINT] = diagnostic_prefix,
      [vim.diagnostic.severity.INFO] = diagnostic_prefix,
    },
  },
}
