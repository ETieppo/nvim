---@class OsInstruction
---@field unix? string|0
---@field windows? string|0
---@field macos? string|0
---@field archlinux? string|0

---@class DepBase
---@field cmd string
---@field min_version? string
---@field version_cmd? string

---@class DepByOs : DepBase
---@field os OsInstruction
---@field install_command? nil

---@class DepByCommand : DepBase
---@field install_command string
---@field os? nil

---@alias DepProps DepByOs | DepByCommand

---@class LangDeps
---@field lang string
---@field deps DepProps[]

local M = {}
local os = require 'utils.os'

---@type LangDeps[]
M.langs = {}

---@param cli DepProps
---@return boolean
local function needs_install(cli)
  if not os.which(cli.cmd) then return true end
  if not cli.min_version then return false end

  local out = vim.fn.system(cli.version_cmd or (cli.cmd .. ' --version'))
  if vim.v.shell_error ~= 0 then return true end

  local raw = out:match '%d+%.%d+%.%d+' or out:match '%d+%.%d+'
  if not raw then return true end

  local ok, v = pcall(vim.version.parse, raw, { strict = false })
  if not ok or not v then return true end

  return vim.version.lt(v, cli.min_version)
end

---@param cli DepProps
---@return string|nil
local function resolve_install(cli)
  local by_os = cli.os or {}
  local cmd = cli.install_command
      or (os.is_windows() and by_os.windows)
      or (os.is_macos() and by_os.macos)
      or (os.is_linux() and by_os.archlinux)
      or by_os.unix

  if cmd == nil or cmd == false or cmd == 0 or cmd == '' then return nil end
  return cmd --[[@as string]]
end

---@param lang string
function M.ensure_lang_deps(lang)
  for _, l in ipairs(M.langs) do
    if lang == l.lang then
      local to_install, skipped = {}, {}

      for _, cli in ipairs(l.deps) do
        if not needs_install(cli) then
          vim.notify(cli.cmd .. ' already installed')
        else
          local cmd = resolve_install(cli)
          if cmd then
            table.insert(to_install, cmd)
          else
            table.insert(skipped, cli.cmd)
          end
        end
      end

      if #skipped > 0 then
        vim.notify(
          'No install command for: ' .. table.concat(skipped, ', '),
          vim.log.levels.WARN
        )
      end
      if #to_install > 0 then os.run_in_terminal(to_install) end
      return
    end
  end
  vim.notify('No config to install\n' .. lang .. ' deps (#_#)')
end

---@param lang_deps LangDeps
function M.register_lang_deps(lang_deps)
  table.insert(M.langs, lang_deps)
end

return M
