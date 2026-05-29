local path = vim.fn.stdpath 'config' .. '/lua/settings'
local files = vim.fn.readdir(path)

for _, file in ipairs(files) do
  if file ~= 'init.lua' and file:sub(-4) == '.lua' then
    local module = 'settings.' .. file:gsub('%.lua$', '')
    require(module)
  end
end
