local helpers = require 'utils.helpers'
local deps_mod = require 'deps.deps_mod'

---@class FormatterConfigProps
---@field command string
---@field stdin boolean
---@field args string[]

---@class FormatterProps
---@field lang? string|string[]
---@field formatter string
---@field config? FormatterConfigProps
---@field deps? ToolDepProps[]

---@class FormattersProps
---@field linkers table<string, string[]>
---@field configs table<string, FormatterConfigProps>

---@class FmtModProps
local M = {}

---@type FormattersProps
local recorded_formatters = {
  linkers = {},
  configs = {},
}

---@type table<string, DepProps[]>
local recorded_deps = {}

---@param fmt FormatterProps
function M.record_fmt(fmt)
  local caller_lang = helpers.get_caller_directory_name()
  local lang_names = helpers.ensure_list(fmt.lang or caller_lang)
  deps_mod.record_tool_deps(
    recorded_deps,
    caller_lang,
    fmt.config and fmt.config.command or fmt.formatter,
    fmt.deps
  )
  local conform = package.loaded.conform
  if fmt.config ~= nil then
    recorded_formatters.configs[fmt.formatter] = fmt.config
    if conform then conform.formatters[fmt.formatter] = fmt.config end
  end
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_formatters.linkers[lang_name] = { fmt.formatter }
    if conform then conform.formatters_by_ft[lang_name] = { fmt.formatter } end
  end
end

---@param lang_name string
---@return DepProps[]
function M.get_deps(lang_name) return recorded_deps[lang_name] or {} end

---@return FormattersProps
function M.get_formatters() return vim.deepcopy(recorded_formatters) end

return M
