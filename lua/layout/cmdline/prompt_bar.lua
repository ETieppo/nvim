---@class PromptBarProps
---@field window_config vim.api.keyset.win_config
---@field window_highlight string

---@type PromptBarProps
return {
  window_config = {
    relative = 'editor',
    row = 0,
    col = 0,
    height = 1,
    border = 'none',
    zindex = 200,
  },
  window_highlight = 'NormalFloat:MsgArea',
}
