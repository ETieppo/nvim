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

---@class LangCmdsProps
---@field short string
---@field func function

local M = {}
local os_mod = require 'utils.os_mod'
local helpers_mod = require 'utils.helpers'

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
    if not helpers.needs_install(cli) then
      vim.notify(cli.cmd .. ' already installed')
    else
      local cmd = helpers.resolve_install(cli)
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
  if #to_install > 0 then os_mod.run_in_terminal(to_install) end
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
    if type(treesitters) == 'string' then
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
  if fmt.config ~= nil then M.formatters.configs[fmt.formatter] = fmt.config end
  M.formatters.linkers[fmt.lang] = { fmt.formatter }
end

---@param lint LintProps
function M.record_linter(lint) M.linters[lint.lang] = { lint.linter } end

function M.ignore_treesitter_install()
  local src = debug.getinfo(2, 'S').source
  local to_ignore = vim.fn.fnamemodify(src:sub(2), ':t:r')
  table.insert(M.ignore_at_treesitter, to_ignore)
end

---@type table<string, LangCmdsProps>
local lang_commands = {
  install = {
    short = 'i',
    func = M.ensure_lang_deps,
  },
}

vim.api.nvim_create_user_command('Lang', function(opts)
  local char = '--_--'
  local lang_cmd_arg = opts.fargs[1]
  local lang_name_arg = opts.fargs[2]

  if lang_cmd_arg == nil or lang_name_arg == nil then
    vim.notify('Not enough args\nUse :Lang <command> <language>\n' .. char)
    return
  end

  local refered_command = lang_commands[lang_cmd_arg]
    or (function()
      for _, cmd_items in pairs(lang_commands) do
        if cmd_items.short == lang_cmd_arg then return cmd_items end
      end
    end)()

  if refered_command == nil then
    vim.notify('No ' .. lang_cmd_arg .. ' Lang command found! ' .. char)
    return
  end

  refered_command.func(lang_name_arg)
end, {
  nargs = '+',
  complete = function(arg_lead, cmdline)
    if #vim.split(cmdline, '%s+') > 2 then return {} end
    local names = vim.tbl_keys(lang_commands)
    table.sort(names)
    return vim.tbl_filter(
      function(n) return vim.startswith(n, arg_lead) end,
      names
    )
  end,
})

return M
