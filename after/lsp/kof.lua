local kinds = vim.lsp.protocol.CompletionItemKind

local function normalize_items(result)
  if type(result) ~= 'table' then return end
  local items = result.items or result
  for _, item in ipairs(items) do
    if type(item.kind) == 'string' then
      item.kind = kinds[item.kind] or kinds.Text
    end
  end
end

local normalized = {
  ['textDocument/completion'] = normalize_items,
  ['completionItem/resolve'] = function(item) normalize_items { item } end,
}

return {
  cmd = { 'kof', 'lsp' },
  filetypes = { 'kof' },
  root_markers = { 'kofdeps', 'kof.toml', '.git' },
  on_init = function(client)
    local request = client.request
    client.request = function(self, method, params, handler, ...)
      local normalize = normalized[method]
      if normalize and handler then
        local original = handler
        handler = function(err, result, ...)
          if not err then normalize(result) end
          return original(err, result, ...)
        end
      end
      return request(self, method, params, handler, ...)
    end
  end,
}
