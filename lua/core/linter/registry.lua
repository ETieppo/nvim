local helpers = require 'utils.helpers'
local deps_mod = require 'deps.deps_mod'

---@class LinterOverrideProps
---@field cmd? string

---@class LinterProps
---@field lang? string|string[]
---@field linter string
---@field config? lint.Linter|LinterOverrideProps
---@field deps? ToolDepProps[]

---@class LintersProps
---@field linkers table<string, string[]>
---@field configs table<string, lint.Linter|LinterOverrideProps>

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
  local nvim_lint = package.loaded.lint
  if lint.config ~= nil then
    recorded_linters.configs[lint.linter] = lint.config
    if nvim_lint then
      M.apply_linter_config(nvim_lint, lint.linter, lint.config)
    end
  end
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_linters.linkers[lang_name] = { lint.linter }
    if nvim_lint then nvim_lint.linters_by_ft[lang_name] = { lint.linter } end
  end
end

---@param nvim_lint table
---@param linter_name string
---@param linter_config lint.Linter|LinterOverrideProps
function M.apply_linter_config(nvim_lint, linter_name, linter_config)
  local builtin_linter = nvim_lint.linters[linter_name]
  nvim_lint.linters[linter_name] = type(builtin_linter) == 'table'
      and vim.tbl_extend('force', builtin_linter, linter_config)
    or linter_config
end

---@param lang_name string
---@return DepProps[]
function M.get_deps(lang_name) return recorded_deps[lang_name] or {} end

---@return LintersProps
function M.get_linters() return vim.deepcopy(recorded_linters) end

return M
