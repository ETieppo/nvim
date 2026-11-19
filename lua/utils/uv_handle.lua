local M = {}

---@param handle uv.uv_handle_t
function M.close(handle)
  if not handle:is_closing() then handle:close() end
end

return M
