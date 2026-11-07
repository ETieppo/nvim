local M = {}

M.IGNORE_CASE_FLAG = '\\c'
M.MATCH_CASE_FLAG = '\\C'

---@param text string
---@return boolean
function M.should_ignore_case(text)
  if not vim.o.ignorecase then return false end
  if not vim.o.smartcase then return true end

  local unescaped_text = text:gsub('\\.', '')
  return unescaped_text:find '%u' == nil
end

---@param pattern string
---@return string
function M.get_case_flag(pattern)
  return M.should_ignore_case(pattern) and M.IGNORE_CASE_FLAG
    or M.MATCH_CASE_FLAG
end

return M
