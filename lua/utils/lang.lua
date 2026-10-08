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

---@class FormatterProps
---@field lang string
---@field config FmtProps | nil
---@field formatter string

---@class FmtProps
---@field command string
---@field stdin boolean
---@field args string[]

---@class LintProps
---@field lang string
---@field linter string

local M = {}
local os = require 'utils.os'

---@type LangDeps[]
M.langs = {}
M.test_adapters = {}
M.linters = {}
M.ignore_treesitter_install = {}
M.formatters = {
  linkers = {},
  configs = {},
}

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
  local _ = vim.lsp.config[lang]
  local l = M.langs[lang]
  local to_install, skipped = {}, {}

  if not l then
    vim.notify('No config to install\n' .. lang .. ' deps (#_#)')
    return
  end

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
end

---@param lang LangDeps
function M.record_lang_deps(lang) M.langs[lang.lang] = lang end

function M.record_test_adapter(test_adapter)
  if require('settings.profile').is_max_profile() then
    vim.list_extend(M.test_adapters, { test_adapter })
  end
end

---@param fmt FormatterProps | FormatterProps[]
function M.record_fmt(fmt)
  local function register(item)
    if item.config ~= nil then
      M.formatters.configs[item.formatter] = item.config
    end
    M.formatters.linkers[item.lang] = item.formatter
  end

  if type(fmt) == 'table' then
    for _, item in ipairs(fmt) do
      register(item)
    end
  else
    register(fmt)
  end
end

---@param lint LintProps
function M.record_linter(lint)
  M.linters[lint.lang] = lint.linter
end

function M.ignore_at_treesitter()
  local src = debug.getinfo(2, 'S').source
  local to_ignore = vim.fn.fnamemodify(src:sub(2), ':t:r')
  table.insert(M.ignore_treesitter_install, to_ignore)
end

return M
