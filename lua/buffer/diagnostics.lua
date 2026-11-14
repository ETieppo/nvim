local DIAGNOSTIC_PREFIX = '🭰'
local DIAGNOSTIC_SUFFIX = '🭵'
local DIAGNOSTIC_PREFIX_WIDTH = vim.api.nvim_strwidth(DIAGNOSTIC_PREFIX)

local function wrap_virtual_diagnostic(diagnostic)
  local win = vim.fn.bufwinid(diagnostic.bufnr)
  if win == -1 then win = vim.api.nvim_get_current_win() end

  local textoff = vim.fn.getwininfo(win)[1].textoff
  local width =
    math.max(vim.api.nvim_win_get_width(win) - textoff - diagnostic.col - 6, 20)

  local lines = {}
  for _, paragraph in ipairs(vim.split(diagnostic.message, '\n')) do
    local line, line_width = DIAGNOSTIC_PREFIX, DIAGNOSTIC_PREFIX_WIDTH
    for word in paragraph:gmatch '%S+' do
      local word_width = vim.api.nvim_strwidth(word)
      if line_width + 1 + word_width > width then
        table.insert(lines, line)
        line, line_width = word, word_width
      else
        line, line_width = line .. ' ' .. word, line_width + 1 + word_width
      end
    end
    table.insert(lines, line .. DIAGNOSTIC_SUFFIX)
  end

  return table.concat(lines, '\n')
end

---@class VirtualLinesExtmarkDetailsProps : vim.api.keyset.extmark_details
---@field virt_lines_overflow? string

local builtin_virtual_lines_handler = vim.diagnostic.handlers.virtual_lines

local function highlight_virtual_lines_messages(namespace, bufnr)
  ---@type integer|nil
  local virtual_lines_namespace =
    vim.diagnostic.get_namespace(namespace).user_data.virt_lines_ns
  if not virtual_lines_namespace or not vim.api.nvim_buf_is_loaded(bufnr) then
    return
  end

  local extmarks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    virtual_lines_namespace,
    0,
    -1,
    { details = true }
  )

  for _, extmark in ipairs(extmarks) do
    ---@type integer, integer, integer, VirtualLinesExtmarkDetailsProps
    local id, row, col, details = unpack(extmark)
    for _, virtual_line in ipairs(details.virt_lines or {}) do
      local message_chunk = virtual_line[#virtual_line]
      if message_chunk and type(message_chunk[2]) == 'string' then
        message_chunk[2] = message_chunk[2]:gsub(
          '^DiagnosticVirtualLines',
          'DiagnosticVirtualText'
        )
      end
    end
    vim.api.nvim_buf_set_extmark(bufnr, virtual_lines_namespace, row, col, {
      id = id,
      virt_lines = details.virt_lines,
      virt_lines_overflow = details.virt_lines_overflow,
    })
  end
end

vim.diagnostic.handlers.virtual_lines = {
  show = function(namespace, bufnr, diagnostics, opts)
    builtin_virtual_lines_handler.show(namespace, bufnr, diagnostics, opts)
    highlight_virtual_lines_messages(namespace, bufnr)
  end,
  hide = builtin_virtual_lines_handler.hide,
}

vim.diagnostic.config {
  virtual_text = false,
  virtual_lines = {
    format = wrap_virtual_diagnostic,
  },
  severity_sort = true,
  underline = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.WARN] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.HINT] = DIAGNOSTIC_PREFIX,
      [vim.diagnostic.severity.INFO] = DIAGNOSTIC_PREFIX,
    },
  },
}
-- vim.diagnostic.config {
--   virtual_text = {
--     enabled = true,
--     prefix = diagnostic_prefix,
--     suffix = diagnostic_suffix,
--   },
--   underline = true,
--   signs = {
--     text = {
--       [vim.diagnostic.severity.ERROR] = diagnostic_prefix,
--       [vim.diagnostic.severity.WARN] = diagnostic_prefix,
--       [vim.diagnostic.severity.HINT] = diagnostic_prefix,
--       [vim.diagnostic.severity.INFO] = diagnostic_prefix,
--     },
--   },
-- }
