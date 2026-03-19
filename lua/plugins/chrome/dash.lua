math.randomseed(os.time())

local path = vim.fn.expand '~/.config/nvim/assets/'
local dir_files = vim.fn.readdir(path)
local images = {}
local allowed_file_types = { 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp' }
local function is_allowed_file(fname) return vim.tbl_contains(allowed_file_types, vim.fn.fnamemodify(fname, ':e'):lower()) end
local wall_selection

for _, f in ipairs(dir_files) do
  if is_allowed_file(f) then table.insert(images, f) end
end

wall_selection = images[math.random(1, #images)]

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
