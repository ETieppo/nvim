local M = {}

function M.scan_modules_imports(dir, prefix, opts)
  opts = opts or {}
  local exclude = opts.exclude or {}
  local uv = vim.uv or vim.loop
  local imports = {}
  local handle = uv.fs_scandir(dir)
  if not handle then return imports end
  local subdirs = {}
  local has_lua = false
  while true do
    local name, type = uv.fs_scandir_next(handle)
    if not name then break end
    if type == 'directory' then
      subdirs[#subdirs + 1] = name
    elseif name:sub(-4) == '.lua' then
      has_lua = true
    end
  end
  if has_lua then imports[#imports + 1] = { import = prefix } end
  for _, name in ipairs(subdirs) do
    local module = prefix .. '.' .. name
    if not exclude[module] then
      vim.list_extend(
        imports,
        M.scan_modules_imports(dir .. '/' .. name, module, opts)
      )
    end
  end
  return imports
end

return M
