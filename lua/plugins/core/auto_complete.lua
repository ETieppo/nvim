local function notify(msg, level)
  vim.schedule(
    function()
      vim.notify(
        msg,
        level or vim.log.levels.ERROR,
        { title = 'blink.cmp', id = 'blink.cmp' }
      )
    end
  )
end

---@param fn function?
local function print_to_notify(fn)
  if type(fn) ~= 'function' then return end
  local proxy = setmetatable({
    print = function(msg, ...)
      notify(tostring(msg))
      return msg, ...
    end,
  }, { __index = vim })
  setfenv(fn, setmetatable({ vim = proxy }, { __index = getfenv(fn) }))
end

return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'super-tab',
      ['<Up>'] = {},
      ['<Down>'] = {},
      ['<M-j>'] = { 'select_next', 'fallback' },
      ['<M-k>'] = { 'select_prev', 'fallback' },
      ['<D-j>'] = { 'select_next', 'fallback' },
      ['<D-k>'] = { 'select_prev', 'fallback' },
    },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 500 },
      menu = {
        draw = {
          components = {
            lsp_detail = {
              text = function(ctx)
                local detail = ctx.item.detail
                if not detail or detail == '' then return '' end
                return detail:match '^[^\n]+' or ''
              end,
              highlight = 'NonText',
            },
          },
          columns = {
            { 'label',      'label_description', gap = 1 },
            { 'kind_icon',  'kind',              gap = 1 },
            { 'lsp_detail' },
            { 'source_name' },
          },
        },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = 'LazyDev',
          module = 'lazydev.integrations.blink',
          score_offset = 100,
        },
      },
    },
  },
  config = function(_, opts)
    require('blink.cmp.lib.utils').notify = function(chunks, level)
      local text = {}
      for _, chunk in ipairs(chunks) do
        text[#text + 1] = chunk[1]
      end
      notify(table.concat(text), level or vim.log.levels.WARN)
    end

    require('blink.cmp').setup(opts)

    local renderer = require 'blink.cmp.completion.windows.render'
    local draw = renderer.draw
    renderer.draw = function(self, ...)
      local ok, columns = pcall(draw, self, ...)
      if ok then return columns end
      notify('menu render failed: ' .. tostring(columns))
      return self.columns or {}
    end

    local sources = require 'blink.cmp.sources.lib'
    print_to_notify(require('blink.cmp.sources.lib.tree').get_completions)
    print_to_notify(sources.resolve)
    print_to_notify(sources.execute)
  end,
}
