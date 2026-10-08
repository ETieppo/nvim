local M = {}

local function scan_imported_modules(dir, prefix, opts)
  opts = opts or {}
  local exclude = opts.exclude or {}
  local uv = vim.uv or vim.loop
  local imports = {}
  local handle = uv.fs_scandir(dir)
  local subdirs = {}
  local has_lua = false

  if not handle then return imports end

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
        scan_imported_modules(dir .. '/' .. name, module, opts)
      )
    end
  end

  return imports
end

function M.get_this_filename()
  local src = debug.getinfo(2, 'S').source
  return vim.fn.fnamemodify(src:sub(2), ':t:r')
end

function M.find_modules(base_dir, prefix, opts)
  local dir = (vim.fn.stdpath 'config') .. base_dir
  return scan_imported_modules(dir, prefix, opts)
end

return M
