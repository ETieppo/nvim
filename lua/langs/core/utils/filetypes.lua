local JAVASCRIPT_FILETYPES = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
}

local M = {}

---@return string[]
function M.get_javascript_filetypes() return vim.deepcopy(JAVASCRIPT_FILETYPES) end

return M
