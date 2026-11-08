local helpers = require 'utils.helpers'

---@class FormatterConfigProps
---@field command string
---@field stdin boolean
---@field args string[]

---@class FormatterProps
---@field lang? string|string[]
---@field formatter string
---@field config? FormatterConfigProps

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

---@param fmt FormatterProps
function M.record_fmt(fmt)
  local lang_names =
    helpers.ensure_list(fmt.lang or helpers.get_caller_filename())
  if fmt.config ~= nil then
    recorded_formatters.configs[fmt.formatter] = fmt.config
  end
  for _, lang_name in ipairs(lang_names) do
    ---@cast lang_name string
    recorded_formatters.linkers[lang_name] = { fmt.formatter }
  end
end

---@return FormattersProps
function M.get_formatters() return vim.deepcopy(recorded_formatters) end

return M
