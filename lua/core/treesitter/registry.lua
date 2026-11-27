local helpers = require 'utils.helpers'
local ignorable_registry = require 'utils.ignorable_registry'

---@class TreesitterInstallInfoProps
---@field url string
---@field revision? string
---@field branch? string
---@field location? string
---@field generate? boolean
---@field generate_from_json? boolean
---@field queries? string

---@class TreesitterModProps
local M = {}

local treesitter_registry = ignorable_registry.new()

---@type table<string, TreesitterInstallInfoProps>
local recorded_install_infos = {}

---@param treesitter_name string
---@param install_info? TreesitterInstallInfoProps
function M.record_treesitter(treesitter_name, install_info)
  ignorable_registry.record(treesitter_registry, treesitter_name)
  if install_info then
    recorded_install_infos[treesitter_name] = install_info
  end
end

function M.treesitter_ignore()
  ignorable_registry.ignore(treesitter_registry, helpers.get_caller_filename())
end

---@return table<string, TreesitterInstallInfoProps>
function M.get_install_infos() return vim.deepcopy(recorded_install_infos) end

---@return string[]
function M.get_treesitters_to_install()
  return ignorable_registry.get_recorded(treesitter_registry)
end

return M
