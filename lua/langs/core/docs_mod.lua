local helpers = require 'utils.helpers'

local M = {}

---@type string[]
local recorded_docs = {}

---@type string[]
local ignored_docs = {}

---@param docs string[]
function M.record_docs(docs)
  for _, doc in ipairs(docs) do
    if
      vim.list_contains(ignored_docs, doc)
      or vim.list_contains(recorded_docs, doc)
    then
      return
    end
    table.insert(recorded_docs, doc)
  end
end

---@param lang string?
function M.docs_ignore(lang)
  local lang_name = lang or helpers.get_caller_filename()
  if not vim.list_contains(ignored_docs, lang_name) then
    table.insert(ignored_docs, lang_name)
  end
end

---@return string[]
function M.get_docs() return vim.deepcopy(recorded_docs) end

return M
