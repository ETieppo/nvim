local helpers = require 'utils.helpers'
local ignorable_registry = require 'utils.ignorable_registry'

---@class TreesitterModProps
local M = {}

local treesitter_registry = ignorable_registry.new()

---@param treesitter_name string
function M.record_treesitter(treesitter_name)
  ignorable_registry.record(treesitter_registry, treesitter_name)
end

function M.treesitter_ignore()
  ignorable_registry.ignore(treesitter_registry, helpers.get_caller_filename())
end

---@return string[]
function M.get_treesitters_to_install()
  return ignorable_registry.get_recorded(treesitter_registry)
end

return M
