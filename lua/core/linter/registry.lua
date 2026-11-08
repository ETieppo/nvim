local helpers = require 'utils.helpers'

---@class LinterProps
---@field lang? string|string[]
---@field linter string

---@class LintModProps
local M = {}

---@type table<string, string[]>
local recorded_linters = {}

---@param lint LinterProps
function M.record_linter(lint)
  local lang_names =
    helpers.ensure_list(lint.lang or helpers.get_caller_filename())
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_linters[lang_name] = { lint.linter }
  end
end

---@return table<string, string[]>
function M.get_linters() return vim.deepcopy(recorded_linters) end

return M
