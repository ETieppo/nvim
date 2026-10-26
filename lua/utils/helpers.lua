local os_mod = require 'utils.os_mod'
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

---@param cli DepProps
---@return boolean
function M.needs_install(cli)
  if not os_mod.has_deps(cli.cmd) then return true end
  if not cli.min_version then return false end

  local out = vim.fn.system(cli.version_cmd or (cli.cmd .. ' --version'))
  if vim.v.shell_error ~= 0 then return true end

  local raw = out:match '%d+%.%d+%.%d+' or out:match '%d+%.%d+'
  if not raw then return true end

  local ok, v = pcall(vim.version.parse, raw, { strict = false })
  if not ok or not v then return true end

  return vim.version.lt(v, cli.min_version)
end

---@param cmd string
---@return string
local function add_noconfirm(cmd)
  if cmd:find('--noconfirm', 1, true) then return cmd end
  for _, pm in ipairs { 'pacman', 'yay' } do
    local new, n = cmd:gsub('(' .. pm .. '%s+%-S%a*)', '%1 --noconfirm', 1)
    if n > 0 then return new end
  end
  return cmd
end

---@param cli DepProps
---@return string|nil
function M.resolve_install(cli)
  local by_os = cli.os or {}
  local cmd = cli.install_command
    or (os_mod.is_windows() and by_os.windows)
    or (os_mod.is_macos() and by_os.macos)
    or (os_mod.is_linux() and by_os.archlinux)
    or by_os.unix

  if cmd == nil or cmd == false or cmd == 0 or cmd == '' then return nil end
  ---@cast cmd string

  if os_mod.is_linux() then
    if cmd:find('pacman', 1, true) and not cmd:find('sudo', 1, true) then
      cmd = 'sudo ' .. cmd
    end
    cmd = add_noconfirm(cmd)
  end

  return cmd
end

return M
