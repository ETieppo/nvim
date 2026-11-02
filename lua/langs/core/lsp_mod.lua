local M = {}

---@type string[]
local recorded_lsps = {}

---@param lsp_name string
---@param config vim.lsp.Config|nil
function M.record_lsp_config(lsp_name, config)
  if not config or vim.list_contains(recorded_lsps, lsp_name) then return end
  vim.lsp.config(lsp_name, config)
  table.insert(recorded_lsps, lsp_name)
end

---@return string[]
function M.get_lsps() return vim.deepcopy(recorded_lsps) end

return M
