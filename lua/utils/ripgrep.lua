local DEFAULT_EXCLUDED_GLOBS = {
  '.git/',
  'imgs/',
  'images/',
  'videos/',
  'fonts/',
  'assets/',
  'bun.lock',
  'package-lock.json',
  'Cargo.lock',
  '.angular/',
}
local HIDDEN_FILES_ARGS = { '--hidden', '--follow' }

local M = {}

---@param args string[]
---@param excluded_globs? string[]
---@return string[]
function M.build_command(args, excluded_globs)
  local command = vim.list_extend({ 'rg' }, args)
  vim.list_extend(command, HIDDEN_FILES_ARGS)
  for _, glob in ipairs(excluded_globs or DEFAULT_EXCLUDED_GLOBS) do
    table.insert(command, '--glob=!' .. glob)
  end
  return command
end

return M
