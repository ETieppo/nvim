local helpers = require 'utils.helpers'

---@class TreesitterModProps
local M = {}

---@type string[]
local treesitters_to_install = {}

---@type string[]
local ignored_treesitters = {}

---@param treesitter_name string
function M.record_treesitter(treesitter_name)
  if
    vim.list_contains(ignored_treesitters, treesitter_name)
    or vim.list_contains(treesitters_to_install, treesitter_name)
  then
    return
  end
  table.insert(treesitters_to_install, treesitter_name)
end

function M.treesitter_ignore()
  local lang_name = helpers.get_caller_filename()
  if not vim.list_contains(ignored_treesitters, lang_name) then
    table.insert(ignored_treesitters, lang_name)
  end
end

---@return string[]
function M.get_treesitters_to_install()
  return vim.deepcopy(treesitters_to_install)
end

return M
