local helpers = require 'utils.helpers'
local lang_registry = require 'core.lang.registry'
local deps_mod = require 'deps.deps_mod'

---@type string
local COMPLETION_RESOLVE_METHOD = 'completionItem/resolve'
---@type table<string, boolean>
local METHODS_RETURNING_COMPLETION_ITEMS = {
  ['textDocument/completion'] = true,
  [COMPLETION_RESOLVE_METHOD] = true,
}

---@class LspProps : vim.lsp.Config
---@field deps? ToolDepProps[]
---@field capabilities? lsp.ClientCapabilities|fun(): lsp.ClientCapabilities

---@class RawCompletionItemProps
---@field kind? string|integer

---@class LspModProps
local M = {}

---@type string[]
local recorded_lsps = {}

---@type table<string, LspProps>
local recorded_configs = {}

---@type table<string, DepProps[]>
local recorded_deps = {}

local are_lsps_enabled = false

---@param method string
---@param result any
local function convert_kind_names_to_numbers(method, result)
  if type(result) ~= 'table' then return end

  ---@type RawCompletionItemProps[]
  local items = method == COMPLETION_RESOLVE_METHOD and { result }
    or result.items
    or result
  local completion_item_kinds = vim.lsp.protocol.CompletionItemKind
  for _, item in ipairs(items) do
    if type(item.kind) == 'string' then
      item.kind = completion_item_kinds[item.kind] or completion_item_kinds.Text
    end
  end
end

---@param client vim.lsp.Client
function M.convert_completion_kind_names_on_init(client)
  local send_request = client.request
  client.request = function(self, method, params, handler, ...)
    if METHODS_RETURNING_COMPLETION_ITEMS[method] and handler then
      local original_handler = handler
      handler = function(err, result, ...)
        if not err then convert_kind_names_to_numbers(method, result) end
        return original_handler(err, result, ...)
      end
    end
    return send_request(self, method, params, handler, ...)
  end
end

---@param lsp_name string
local function apply_lsp_config(lsp_name)
  local config = recorded_configs[lsp_name]
  if type(config.capabilities) == 'function' then
    config.capabilities = config.capabilities()
  end
  vim.lsp.config(lsp_name, config)
end

---@param config LspProps
function M.record_lsp(config)
  local lang_name = helpers.get_caller_directory_name()
  local lsp_name = lang_registry.resolve_lsp_name(lang_name)
  if vim.list_contains(recorded_lsps, lsp_name) then return end
  deps_mod.record_tool_deps(
    recorded_deps,
    lang_name,
    type(config.cmd) == 'table' and config.cmd[1] or nil,
    config.deps
  )
  config.deps = nil
  recorded_configs[lsp_name] = config
  table.insert(recorded_lsps, lsp_name)
  if are_lsps_enabled then
    apply_lsp_config(lsp_name)
    vim.lsp.enable(lsp_name)
  end
end

---@param lang_name string
---@return DepProps[]
function M.get_deps(lang_name) return recorded_deps[lang_name] or {} end

function M.enable_lsps()
  are_lsps_enabled = true
  for _, lsp_name in ipairs(recorded_lsps) do
    apply_lsp_config(lsp_name)
  end
  vim.lsp.enable(recorded_lsps)
end

return M
