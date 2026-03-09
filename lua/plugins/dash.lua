return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    dashboard = {
      sections = {
        {
          section = 'terminal',
          cmd = 'pixterm -s 1 -d 2 -nobg ~/Downloads/craiyon_164341_Skeleton_in_pixelart_with_a_black_fedora__no_eyes__acid_dripping_from_hat.png',
          height = 30,
          padding = 1,
        },
        {
          section = 'projects',
          title = 'Projetos recentes',
          limit = 5,
          padding = 1,
        },
      },
    },
  },
}
