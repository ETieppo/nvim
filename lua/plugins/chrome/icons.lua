return {
  'DaikyXendo/nvim-material-icon',
  enabled = vim.g.have_nerd_font,
  main = 'nvim-web-devicons',
  opts = {
    default = true,
    color_icons = true,
    override = {
      tl = {
        icon = '\u{100000}',
        color = '#00B1BC',
        name = 'Teal',
      },
      kof = {
        icon = '\u{100001}',
        color = '#FFFFFF',
        name = 'Kf',
      },
      kf = {
        icon = '\u{100001}',
        color = '#FFFFFF',
        name = 'Kof',
      },
    },
  },
}
