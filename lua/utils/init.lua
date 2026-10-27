local path = vim.fn.stdpath 'config' .. '/lua/utils'
local files = vim.fn.readdir(path)

for _, file in ipairs(files) do
  if file ~= 'init.lua' and file:sub(-4) == '.lua' then
    local module = 'utils.' .. file:gsub('%.lua$', '')
    require(module)
  end
end
