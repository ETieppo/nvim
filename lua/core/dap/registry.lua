local helpers = require 'utils.helpers'
local os_mod = require 'deps.sys'
local deps_mod = require 'deps.deps_mod'

---@class DapAdapterProps
---@field name string
---@field cmd string
---@field args? string[]
---@field availability_check_args? string[]
---@field build? fun(path: string): dap.Adapter
---@field configuration_defaults? table
---@field deps? ToolDepProps[]

---@class DapProps
---@field lang? string
---@field adapter string|DapAdapterProps
---@field filetypes? string[]
---@field configurations? table[]
---@field provider? fun(buffer: integer): table[]

---@class DapProvidersRegistryProps
---@field configs table<string, fun(buffer: integer): table[]>

---@class DapRegistryProps
---@field providers DapProvidersRegistryProps
---@field configurations table<string, table[]>

---@class RecordedDapProps : DapProps
---@field lang string
---@field adapter string
---@field filetypes string[]

---@return string
local function ask_executable()
  return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
end

---@class DapModProps
local M = {}

local CONFIGURATION_DEFAULTS = {
  name = 'Launch file',
  request = 'launch',
  cwd = '${workspaceFolder}',
}

---@type table<string, DapAdapterProps>
local recorded_adapters = {
  lldb = {
    name = 'lldb',
    cmd = 'lldb-dap',
    configuration_defaults = {
      name = 'Debug (lldb)',
      program = ask_executable,
      args = {},
      stopOnEntry = false,
    },
  },
}

---@type table<string, RecordedDapProps>
local recorded_daps = {}

---@type table<string, DepProps[]>
local recorded_deps = {}

---@param dap DapProps
function M.record_dap(dap)
  local lang_name = dap.lang or helpers.get_caller_directory_name()
  if dap.configurations and dap.provider then
    error(
      lang_name .. ': record_dap needs configurations or provider, not both'
    )
  end

  local adapter = dap.adapter
  local adapter_name = adapter
  if type(adapter) == 'table' then
    adapter_name = adapter.name
    recorded_adapters[adapter.name] = adapter
    deps_mod.record_tool_deps(
      recorded_deps,
      lang_name,
      adapter.cmd,
      adapter.deps
    )
  end
  ---@cast adapter_name string

  recorded_daps[lang_name] = {
    lang = lang_name,
    adapter = adapter_name,
    filetypes = dap.filetypes or { lang_name },
    configurations = dap.configurations,
    provider = dap.provider,
  }
end

---@param lang_name string
---@return DepProps[]
function M.get_deps(lang_name) return recorded_deps[lang_name] or {} end

---@param find_program fun(): string|table|nil
---@return fun(): string|table
function M.create_program_with_prompt_fallback(find_program)
  return function() return find_program() or ask_executable() end
end

---@param adapter DapAdapterProps
---@param path string
---@return dap.Adapter
local function build_adapter(adapter, path)
  if adapter.build then return adapter.build(path) end
  return { type = 'executable', command = path, args = adapter.args }
end

---@param adapter DapAdapterProps
---@return string|nil
local function resolve_adapter_path(adapter)
  local path = os_mod.which(adapter.cmd)
  if not path then return nil end

  local check_args = adapter.availability_check_args
  if
    check_args and not os_mod.read_program_stdout { path, unpack(check_args) }
  then
    return nil
  end
  return path
end

---@param dap table
---@param record RecordedDapProps
local function register_dap_record(dap, record)
  ---@cast dap DapRegistryProps
  if record.provider then
    dap.providers.configs[record.lang] = record.provider
    return
  end

  local adapter_defaults =
    recorded_adapters[record.adapter].configuration_defaults
  local configurations = vim.tbl_map(
    ---@param configuration table
    ---@return table
    function(configuration)
      return vim.tbl_extend(
        'force',
        CONFIGURATION_DEFAULTS,
        { type = record.adapter },
        adapter_defaults or {},
        configuration
      )
    end,
    record.configurations or { {} }
  )
  for _, filetype in ipairs(record.filetypes) do
    dap.configurations[filetype] =
      vim.list_extend(dap.configurations[filetype] or {}, configurations)
  end
end

function M.setup_dap()
  local dap = require 'dap'
  ---@type table<string, boolean>
  local available_adapters = {}

  for name, adapter in pairs(recorded_adapters) do
    local path = resolve_adapter_path(adapter)
    if path then
      dap.adapters[name] = build_adapter(adapter, path)
      available_adapters[name] = true
    end
  end

  for _, record in pairs(recorded_daps) do
    if available_adapters[record.adapter] then
      register_dap_record(dap, record)
    end
  end
end

return M
