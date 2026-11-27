local helpers = require 'utils.helpers'
local deps_mod = require 'deps.deps_mod'

---@class LinterProps
---@field lang? string|string[]
---@field linter string
---@field config? lint.Linter
---@field deps? ToolDepProps[]

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

---@type table<string, DepProps[]>
local recorded_deps = {}

---@param lint LinterProps
function M.record_linter(lint)
  local caller_lang = helpers.get_caller_directory_name()
  local config_cmd = lint.config and lint.config.cmd
  local lang_names = helpers.ensure_list(lint.lang or caller_lang)
  deps_mod.record_tool_deps(
    recorded_deps,
    caller_lang,
    type(config_cmd) == 'string' and config_cmd or lint.linter,
    lint.deps
  )
  if lint.config ~= nil then
    recorded_linters.configs[lint.linter] = lint.config
  end
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_linters.linkers[lang_name] = { lint.linter }
  end
end

---@param lang_name string
---@return DepProps[]
function M.get_deps(lang_name) return recorded_deps[lang_name] or {} end

---@return LintersProps
function M.get_linters() return vim.deepcopy(recorded_linters) end

return M
