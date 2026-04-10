---@module "neominimap.config.meta"
return {
  'Isrothy/neominimap.nvim',
  version = 'v3.x.x',
  lazy = false,
  init = function()
    local mapsize = 10
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36

    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = true,
      float = {
        fix_width = true,
        minimap_width = mapsize,
        close_if_last_window = false,
      },
      win_opt = {
        number = false,
        relativenumber = false,
        statuscolumn = '',
      },
    }
  end,
}
