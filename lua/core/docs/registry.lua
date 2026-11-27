local helpers = require 'utils.helpers'
local ignorable_registry = require 'utils.ignorable_registry'

---@class DocsModProps
local M = {}

local docs_registry = ignorable_registry.new()

---@param docs string[]
function M.record_docs(docs)
  for _, doc in ipairs(docs) do
    ignorable_registry.record(docs_registry, doc)
  end
end

---@param lang string?
function M.docs_ignore(lang)
  ignorable_registry.ignore(
    docs_registry,
    lang or helpers.get_caller_directory_name()
  )
end

---@return string[]
function M.get_docs() return ignorable_registry.get_recorded(docs_registry) end

return M
