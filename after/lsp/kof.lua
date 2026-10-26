local kinds = vim.lsp.protocol.CompletionItemKind
local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.ignore_treesitter_install()

lang_mod.record_fmt {
  lang = lang_name,
  formatter = 'kof_fmt',
  config = {
    command = 'kof',
    args = { 'fmt', '$FILENAME', '-w' },
    stdin = false,
  },
}

lang_mod.record_lang_deps {
  lang = lang_name,
  deps = {
    {
      cmd = 'kfvm',
      os = {
        unix = 'curl -fsSL https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.sh | sh',
        windows = 'irm https://raw.githubusercontent.com/KofLang/Kof4j/lab/tooling/kfvm/install.ps1 | iex',
      },
    },
    {
      cmd = 'kof',
      install_command = 'kfvm u lts',
    },
  },
}

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


vim.filetype.add {
  extension = { kf = 'kof', kof = 'kof' },
}

return {
  cmd = { 'kof', 'lsp' },
  filetypes = { lang_name },
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
