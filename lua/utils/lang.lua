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
---@field short string?
---@field tree_sitter_name (string | string[])?

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

---@type table<string, LangDeps>
M.langs = {}
M.test_adapters = {}
M.linters = {}
M.ignore_at_treesitter = {}
M.install_lang_treesitters = {}
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

---@param cmd string
---@return string
local function add_noconfirm(cmd)
  if cmd:find("--noconfirm", 1, true) then return cmd end
  for _, pm in ipairs({ "pacman", "yay" }) do
    local new, n = cmd:gsub("(" .. pm .. "%s+%-S%a*)", "%1 --noconfirm", 1)
    if n > 0 then return new end
  end
  return cmd
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
  ---@cast cmd string

  if os.is_linux() then
    if cmd:find("pacman", 1, true) and not cmd:find("sudo", 1, true) then
      cmd = "sudo " .. cmd
    end
    cmd = add_noconfirm(cmd)
  end

  return cmd
end

---@param lang_name string
function M.ensure_lang_deps(lang_name)
  local _ = vim.lsp.config[lang_name]
  local lang = M.langs[lang_name]
  local to_install, skipped = {}, {}

  if not lang then
    for _, l in pairs(M.langs) do
      if l.short == lang_name then
        lang = l
        break
      end
    end
  end

  if not lang then
    vim.notify('No config to install\n' .. lang_name .. ' deps (#_#)')
    return
  end

  for _, cli in ipairs(lang.deps) do
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
function M.record_lang_deps(lang)
  ---@param treesitter_name string
  local function handle_tree_sitter_record(treesitter_name)
    if not vim.list_contains(M.ignore_at_treesitter, treesitter_name) then
      table.insert(M.install_lang_treesitters, treesitter_name)
    end
  end

  local treesitters = lang.tree_sitter_name
  if treesitters ~= nil then
    if type(treesitters) == "string" then
      handle_tree_sitter_record(treesitters)
    else
      for _, l in ipairs(treesitters) do
        handle_tree_sitter_record(l)
      end
    end
  else
    handle_tree_sitter_record(lang.lang)
  end

  M.langs[lang.lang] = lang
end

function M.record_test_adapter(test_adapter)
  if require('settings.profile').is_max_profile() then
    vim.list_extend(M.test_adapters, { test_adapter })
  end
end

---@param fmt FormatterProps
function M.record_fmt(fmt)
  if fmt.config ~= nil then
    M.formatters.configs[fmt.formatter] = fmt.config
  end
  M.formatters.linkers[fmt.lang] = { fmt.formatter }
end

---@param lint LintProps
function M.record_linter(lint)
  M.linters[lint.lang] = { lint.linter }
end

function M.ignore_treesitter_install()
  local src = debug.getinfo(2, 'S').source
  local to_ignore = vim.fn.fnamemodify(src:sub(2), ':t:r')
  table.insert(M.ignore_at_treesitter, to_ignore)
end

return M
