local helpers = require 'utils.helpers'

---@class LinterProps
---@field lang? string|string[]
---@field linter string
---@field config? lint.Linter

---@class LintersProps
---@field linkers table<string, string[]>
---@field configs table<string, lint.Linter>

---@class LintModProps
local M = {}

---@type LintersProps
local recorded_linters = {
  linkers = {},
  configs = {},
}

---@param lint LinterProps
function M.record_linter(lint)
  local lang_names =
    helpers.ensure_list(lint.lang or helpers.get_caller_filename())
  if lint.config ~= nil then
    recorded_linters.configs[lint.linter] = lint.config
  end
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_linters.linkers[lang_name] = { lint.linter }
  end
end

---@return LintersProps
function M.get_linters() return vim.deepcopy(recorded_linters) end

return M
