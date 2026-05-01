math.randomseed(os.time())

local path = vim.fn.stdpath 'config' .. '/assets/'
local dir_files = vim.fn.readdir(path)
local wall_selection = dir_files[math.random(2, #dir_files)]

return {
  'folke/snacks.nvim',
  opts = {
    image = {
      enabled = true,
    },
    dashboard = {
      row = 0,
      preset = {
        width = vim.o.columns,
      },
      sections = {
        {
          section = 'terminal',
          cmd = 'bash -c "pixterm -d 2 -s 1 ' .. path .. wall_selection .. '; cat"',
          width = vim.o.columns,
          height = math.floor(vim.o.lines * 0.75),
          padding = 0,
          indent = 0,
          align = 'top',
        },
        {
          section = 'projects',
          padding = 1,
          height = math.max(math.floor(vim.o.lines * 0.55), math.floor(vim.o.lines * 0.45)),
          limit = 5,
        },
        {
          height = math.floor(vim.o.lines * 0.15),
          section = 'startup',
          gap = 1,
        },
      },
    },
  },
}
