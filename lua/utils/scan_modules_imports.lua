local M = {}

function M.scan_modules_imports(dir, prefix)
  local imports = {}
  local handle = vim.loop.fs_scandir(dir)
  if not handle then return imports end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end

    if type == 'directory' then
      local module = prefix .. '.' .. name
      table.insert(imports, { import = module })

      local sub = M.scan_modules_imports(dir .. '/' .. name, module)
      vim.list_extend(imports, sub)
    end
  end

  return imports
end

return M
