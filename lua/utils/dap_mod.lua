local lang_mod = require 'utils.lang_mod'
local os_mod = require 'utils.os_mod'

local M = {}

---@type DapAdapterProps[]
local core_adapters = {
  {
    name = 'lldb',
    cmd = 'lldb-dap',
    build = function(path)
      return { type = 'executable', command = path, name = 'lldb' }
    end,
  },
}

---@return string
function M.ask_executable()
  return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
end

---@return table
function M.build_lldb_launch_configuration()
  return {
    name = 'Debug (lldb)',
    type = 'lldb',
    request = 'launch',
    program = M.ask_executable,
    cwd = '${workspaceFolder}',
    args = {},
    stopOnEntry = false,
  }
end

---@param adapter DapAdapterProps
---@return string|nil
local function resolve_adapter_path(adapter)
  local path = os_mod.which(adapter.cmd)
  if not path then return nil end
  if adapter.check and not adapter.check(path) then return nil end
  return path
end

---@return table<string, DapAdapterProps>
local function get_all_adapters()
  local adapters = vim.tbl_extend('force', {}, lang_mod.dap.adapters)
  for _, adapter in ipairs(core_adapters) do
    adapters[adapter.name] = adapter
  end
  return adapters
end

function M.setup()
  local dap = require 'dap'
  local available_adapters = {}

  for name, adapter in pairs(get_all_adapters()) do
    local path = resolve_adapter_path(adapter)
    if path then
      dap.adapters[name] = adapter.build(path)
      available_adapters[name] = true
    end
  end

  for _, record in pairs(lang_mod.dap.configurations) do
    if available_adapters[record.adapter] then
      for _, filetype in ipairs(record.filetypes) do
        dap.configurations[filetype] = vim.list_extend(
          dap.configurations[filetype] or {},
          record.configurations
        )
      end
    end
  end
end

return M
