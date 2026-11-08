local helpers = require 'utils.helpers'
local lang_registry = require 'core.lang.registry'

local COMPLETION_ITEM_KINDS = vim.lsp.protocol.CompletionItemKind
---@type string
local COMPLETION_RESOLVE_METHOD = 'completionItem/resolve'
---@type table<string, boolean>
local METHODS_RETURNING_COMPLETION_ITEMS = {
  ['textDocument/completion'] = true,
  [COMPLETION_RESOLVE_METHOD] = true,
}

---@class RawCompletionItemProps
---@field kind? string|integer

---@class LspModProps
local M = {}

---@type string[]
local recorded_lsps = {}

---@param method string
---@param result any
local function convert_kind_names_to_numbers(method, result)
  if type(result) ~= 'table' then return end

  ---@type RawCompletionItemProps[]
  local items = method == COMPLETION_RESOLVE_METHOD and { result }
    or result.items
    or result
  for _, item in ipairs(items) do
    if type(item.kind) == 'string' then
      item.kind = COMPLETION_ITEM_KINDS[item.kind] or COMPLETION_ITEM_KINDS.Text
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
---@param config vim.lsp.Config|nil
function M.record_lsp(config)
  local lsp_name = lang_registry.resolve_lsp_name(helpers.get_caller_filename())
  if vim.list_contains(recorded_lsps, lsp_name) then return end
  vim.lsp.config(lsp_name, config)
  table.insert(recorded_lsps, lsp_name)
end

---@return string[]
function M.get_lsps() return vim.deepcopy(recorded_lsps) end

return M
