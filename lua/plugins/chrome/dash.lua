math.randomseed(os.time())

local path = vim.fn.expand '~/.config/nvim/assets/'
local files = vim.fn.readdir(path)
local allowed_file_types = { 'JPEG', 'PNG', 'GIF', 'BMP', 'TIFF', 'WebP' }
local limit = 3
local wall_selection
local f_iterator = 0
local function is_allowed_file(fname) return not not allowed_file_types[vim.fn.fnamemodify(fname, ':e'):lower()] end

while f_iterator <= limit do
  local file_i = math.random(1, #files)
  wall_selection = files[file_i]
  if is_allowed_file() then f_iterator = limit end
  f_iterator = f_iterator + 1
end

return {
  'folke/snacks.nvim',
  opts = {
    dashboard = {
       row = 0,
      preset = {
        width = vim.o.columns,
      },
      sections = {
        {
          section = 'terminal',
          cmd = 'sleep 0.05 && pixterm -d 2 -s 1 ' .. path .. wall_selection,
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
