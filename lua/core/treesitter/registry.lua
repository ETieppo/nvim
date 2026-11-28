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

---@type table<string, string[]>
local recorded_language_filetypes = {}

---@param treesitter_name string
---@param install_info? TreesitterInstallInfoProps
function M.record_treesitter(treesitter_name, install_info)
  if not treesitter_name or treesitter_name == '' then
    vim.notify.error 'No treesitter_name was received, cowardly refused!'
    return
  end
  ignorable_registry.record(treesitter_registry, treesitter_name)
  if install_info then
    recorded_install_infos[treesitter_name] = install_info
  end
end

---@param language string
---@param filetypes string[]
function M.record_language_filetypes(language, filetypes)
  recorded_language_filetypes[language] =
    vim.list_extend(recorded_language_filetypes[language] or {}, filetypes)
end

function M.apply_language_filetypes()
  for language, filetypes in pairs(recorded_language_filetypes) do
    vim.treesitter.language.register(language, filetypes)
  end
end

---@param lang string
function M.treesitter_ignore(lang)
  ignorable_registry.ignore(treesitter_registry, lang)
end

---@return table<string, TreesitterInstallInfoProps>
function M.get_install_infos() return vim.deepcopy(recorded_install_infos) end

---@return string[]
function M.get_treesitters_to_install()
  return ignorable_registry.get_recorded(treesitter_registry)
end

return M
