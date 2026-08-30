local M = {}

---@param dir string
---@param prefix string
---@param opts? { exclude?: table<string, boolean> }
function M.scan_modules_imports(dir, prefix, opts)
  opts = opts or {}
  local exclude = opts.exclude or {}
  local imports = {}
  local uv = vim.uv or vim.loop
  local handle = uv.fs_scandir(dir)

  if not handle then return imports end

  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end
    if type == 'directory' then
      local module = prefix .. '.' .. name
      if not exclude[module] then
        table.insert(imports, { import = module })
        vim.list_extend(
          imports,
          M.scan_modules_imports(dir .. '/' .. name, module, opts)
        )
      end
    end
  end

  return imports
end

return M
