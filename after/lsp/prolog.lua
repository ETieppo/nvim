local kinds = vim.lsp.protocol.CompletionItemKind
local lang_mod = require 'utils.lang_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.ignore_treesitter_install()

-- lang_mod.record_fmt {
--   lang = lang_name,
--   formatter = ,
--   config = {
--     command = ,
--     args = { 'fmt', '$FILENAME', '-w' },
--     stdin = false,
--   },
-- }

lang_mod.record_lang_deps {
  deps = {
    {
      cmd = 'swipl',
      install_command = 'swi-prolog',
    },
    {
      cmd = 'lsp_server',
      check_cmd = 'swipl -g "use_module(library(lsp_server))" -t halt',
      install_command = 'swipl -g "pack_install(lsp_server, [interactive(false)])" -t halt',
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

return {
  cmd = {
    'swipl',
    '-g',
    'use_module(library(lsp_server)).',
    '-g',
    'lsp_server:main',
    '-t',
    'halt',
    '--',
    'stdio',
  },
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
