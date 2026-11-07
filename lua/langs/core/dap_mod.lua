local helpers = require 'utils.helpers'
local os_mod = require 'utils.os_mod'

---@class DapAdapterProps
---@field name string
---@field cmd string
---@field args? string[]
---@field availability_check_args? string[]
---@field build? fun(path: string): dap.Adapter

---@class DapProps
---@field lang? string
---@field adapter string
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
---@field filetypes string[]

---@class DapModProps
local M = {}

---@type table<string, DapAdapterProps>
local recorded_adapters = {
  lldb = {
    name = 'lldb',
    cmd = 'lldb-dap',
  },
}

---@type table<string, RecordedDapProps>
local recorded_daps = {}

---@param adapter DapAdapterProps
function M.record_dap_adapter(adapter) recorded_adapters[adapter.name] = adapter end

---@param dap DapProps
function M.record_dap(dap)
  local lang_name = dap.lang or helpers.get_caller_filename()
  if (dap.configurations == nil) == (dap.provider == nil) then
    error(lang_name .. ': record_dap needs either configurations or provider')
  end

  recorded_daps[lang_name] = {
    lang = lang_name,
    adapter = dap.adapter,
    filetypes = dap.filetypes or { lang_name },
    configurations = dap.configurations,
    provider = dap.provider,
  }
end

---@return string
function M.ask_executable()
  return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
end

---@param find_program fun(): string|table|nil
---@return fun(): string|table
function M.create_program_with_prompt_fallback(find_program)
  return function() return find_program() or M.ask_executable() end
end

---@param overrides? table
---@return table
function M.build_lldb_launch_configuration(overrides)
  return vim.tbl_extend('force', {
    name = 'Debug (lldb)',
    type = 'lldb',
    request = 'launch',
    program = M.ask_executable,
    cwd = '${workspaceFolder}',
    args = {},
    stopOnEntry = false,
  }, overrides or {})
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

  for _, filetype in ipairs(record.filetypes) do
    dap.configurations[filetype] =
      vim.list_extend(dap.configurations[filetype] or {}, record.configurations)
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
