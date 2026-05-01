return { -- Autocompletion
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '1.*',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = 'enter',
    },
    appearance = {
      nerd_font_variant = 'mono',
    },
    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
      menu = {
        draw = {
          components = {
            lsp_detail = {
              text = function(ctx)
                local detail = ctx.item.detail
                if not detail or detail == '' then return '' end
                return detail:match('^[^\n]+') or ''
              end,
              highlight = 'NonText',
            },
          },
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind', gap = 1 },
            { 'lsp_detail' },
            { 'source_name' },
          },
        },
      },
    },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
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
}
