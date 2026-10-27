local helpers = require 'utils.helpers'
local deps_mod = require 'utils.deps_mod'
local LangDepsResolutionDto = require 'utils.dtos.lang_deps_resolution_dto'

---@class LangDepsProps
---@field lang? string
---@field short? string
---@field depends_on? string
---@field deps DepProps[]
---@field tree_sitter_name? string|string[]

---@class RecordedLangProps : LangDepsProps
---@field lang string

---@class FormatterConfigProps
---@field command string
---@field stdin boolean
---@field args string[]

---@class FormatterProps
---@field lang? string
---@field formatter string
---@field config? FormatterConfigProps

---@class FormattersProps
---@field linkers table<string, string[]>
---@field configs table<string, FormatterConfigProps>

---@class LinterProps
---@field lang? string
---@field linter string

---@class TestAdapterProps
---@field [1] string
---@field module string
---@field opts? table

---@class DapAdapterProps
---@field name string
---@field cmd string
---@field check? fun(path: string): boolean
---@field build fun(path: string): table

---@class DapProps
---@field lang? string
---@field adapter string
---@field filetypes? string[]
---@field configurations table[]

---@class RecordedDapProps : DapProps
---@field filetypes string[]

---@class DapRecordsProps
---@field adapters table<string, DapAdapterProps>
---@field configurations table<string, RecordedDapProps>

---@class DocsProps
---@field lang? string
---@field docs string[]

---@class DepsCollectorProps
---@field resolution LangDepsResolutionDto
---@field collected_deps table<DepProps, boolean>
---@field visited_references table<string, boolean>

local M = {}

---@type table<string, RecordedLangProps>
M.langs = {}

---@type TestAdapterProps[]
M.test_adapters = {}

---@type table<string, string[]>
M.linters = {}

---@type string[]
M.ignore_at_treesitter = {}

---@type string[]
M.install_lang_treesitters = {}

---@type FormattersProps
M.formatters = {
  linkers = {},
  configs = {},
}

---@type DapRecordsProps
M.dap = {
  adapters = {},
  configurations = {},
}

---@type table<string, string[]>
M.docs = {}

---@type table<string, boolean>
local checked_langs = {}
local collect_deps

---@param treesitter_name string
local function record_treesitter(treesitter_name)
  if
    vim.list_contains(M.ignore_at_treesitter, treesitter_name)
    or vim.list_contains(M.install_lang_treesitters, treesitter_name)
  then
    return
  end
  table.insert(M.install_lang_treesitters, treesitter_name)
end

---@param name_or_short string
---@return RecordedLangProps|nil
local function find_recorded_lang(name_or_short)
  if M.langs[name_or_short] then return M.langs[name_or_short] end

  for _, lang in pairs(M.langs) do
    if lang.short == name_or_short then return lang end
  end

  return nil
end

local function load_all_lsp_configs()
  for _, path in ipairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
    local _ = vim.lsp.config[vim.fn.fnamemodify(path, ':t:r')]
  end
end

---@param name_or_short string
---@return RecordedLangProps|nil
function M.find_lang(name_or_short)
  local _ = vim.lsp.config[name_or_short]
  local lang = find_recorded_lang(name_or_short)
  if lang then return lang end

  load_all_lsp_configs()
  return find_recorded_lang(name_or_short)
end

---@param cmd string
---@return DepProps[]|nil
local function find_deps_until_cmd(cmd)
  for _, lang in pairs(M.langs) do
    for index, dep in ipairs(lang.deps) do
      if dep.cmd == cmd then return vim.list_slice(lang.deps, 1, index) end
    end
  end
  return nil
end

---@param reference string
---@return DepProps[]|nil
function M.find_referenced_deps(reference)
  local lang = M.find_lang(reference)
  if lang then return lang.deps end
  return find_deps_until_cmd(reference)
end

---@param reference string|nil
---@param collector DepsCollectorProps
local function collect_reference(reference, collector)
  if not reference or collector.visited_references[reference] then return end
  collector.visited_references[reference] = true

  local referenced_deps = M.find_referenced_deps(reference)
  if not referenced_deps then
    table.insert(collector.resolution.unresolved_references, reference)
    return
  end

  collect_deps(referenced_deps, collector)
end

---@param deps DepProps[]
---@param collector DepsCollectorProps
collect_deps = function(deps, collector)
  for _, dep in ipairs(deps) do
    collect_reference(dep.depends_on, collector)
    if not collector.collected_deps[dep] then
      collector.collected_deps[dep] = true
      table.insert(collector.resolution.deps, dep)
    end
  end
end

---@param lang RecordedLangProps
---@return LangDepsResolutionDto
function M.resolve_lang_deps(lang)
  ---@type DepsCollectorProps
  local collector = {
    resolution = LangDepsResolutionDto.new(),
    collected_deps = {},
    visited_references = { [lang.lang] = true },
  }

  collect_reference(lang.depends_on, collector)
  collect_deps(lang.deps, collector)
  return collector.resolution
end

---@param resolution LangDepsResolutionDto
local function notify_unresolved_references(resolution)
  if #resolution.unresolved_references == 0 then return end
  vim.notify(
    'Unknown depends_on: '
      .. table.concat(resolution.unresolved_references, ', '),
    vim.log.levels.WARN
  )
end

---@param name_or_short string
function M.ensure_lang_deps(name_or_short)
  local lang = M.find_lang(name_or_short)
  if not lang then
    vim.notify('No config to install\n' .. name_or_short .. ' deps (#_#)')
    return
  end

  local resolution = M.resolve_lang_deps(lang)
  notify_unresolved_references(resolution)
  deps_mod.install(resolution.deps)
end

---@param lang RecordedLangProps
---@param buffer integer
---@return boolean
local function lang_applies_to_buffer(lang, buffer)
  local config = vim.lsp.config[lang.lang]
  if not config or not config.workspace_required then return true end
  return vim.fs.root(buffer, config.root_markers or {}) ~= nil
end

---@param lang RecordedLangProps
---@return string[]
local function get_lang_filetypes(lang)
  local config = vim.lsp.config[lang.lang]
  return config and config.filetypes or { lang.lang }
end

---@param filetype string
---@param buffer integer
---@return RecordedLangProps[]
function M.find_langs_for_buffer(filetype, buffer)
  return vim.tbl_filter(
    function(lang)
      return vim.list_contains(get_lang_filetypes(lang), filetype)
        and lang_applies_to_buffer(lang, buffer)
    end,
    vim.tbl_values(M.langs)
  )
end

---@param filetype string
---@param buffer integer
function M.warn_missing_lang_deps(filetype, buffer)
  for _, lang in ipairs(M.find_langs_for_buffer(filetype, buffer)) do
    if not checked_langs[lang.lang] then
      checked_langs[lang.lang] = true

      local resolution = M.resolve_lang_deps(lang)
      local missing = deps_mod.find_missing(resolution.deps)
      if #missing > 0 then
        local names = vim.tbl_map(function(dep) return dep.cmd end, missing)
        vim.notify(
          lang.lang
            .. ' is missing deps:\n\n'
            .. table.concat(names, ',\n')
            .. '\n\nRun :Lang i '
            .. (lang.short or lang.lang),
          vim.log.levels.WARN,
          { title = 'Lang' }
        )
      end
    end
  end
end

---@param lang LangDepsProps
function M.record_lang_deps(lang)
  local lang_name = lang.lang or helpers.get_caller_filename()
  local treesitter_names = lang.tree_sitter_name or lang_name
  if type(treesitter_names) == 'string' then
    treesitter_names = { treesitter_names }
  end

  for _, treesitter_name in ipairs(treesitter_names) do
    record_treesitter(treesitter_name)
  end

  M.langs[lang_name] = vim.tbl_extend('force', lang, { lang = lang_name })
end

---@param test_adapter TestAdapterProps
function M.record_test_adapter(test_adapter)
  if require('settings.profile').is_max_profile() then
    table.insert(M.test_adapters, test_adapter)
  end
end

---@param fmt FormatterProps
function M.record_fmt(fmt)
  local lang_name = fmt.lang or helpers.get_caller_filename()
  if fmt.config ~= nil then M.formatters.configs[fmt.formatter] = fmt.config end
  M.formatters.linkers[lang_name] = { fmt.formatter }
end

---@param lint LinterProps
function M.record_linter(lint)
  local lang_name = lint.lang or helpers.get_caller_filename()
  M.linters[lang_name] = { lint.linter }
end

---@param adapter DapAdapterProps
function M.record_dap_adapter(adapter) M.dap.adapters[adapter.name] = adapter end

---@param dap DapProps
function M.record_dap(dap)
  local lang_name = dap.lang or helpers.get_caller_filename()
  M.dap.configurations[lang_name] = vim.tbl_extend('force', dap, {
    lang = lang_name,
    filetypes = dap.filetypes or { lang_name },
  })
end

---@param docs DocsProps
function M.record_docs(docs)
  local lang_name = docs.lang or helpers.get_caller_filename()
  M.docs[lang_name] = docs.docs
end

---@return string[]
function M.get_docs()
  local all_docs = {}
  for _, docs in pairs(M.docs) do
    for _, doc in ipairs(docs) do
      if not vim.list_contains(all_docs, doc) then
        table.insert(all_docs, doc)
      end
    end
  end
  table.sort(all_docs)
  return all_docs
end

function M.ignore_treesitter_install()
  local lang_name = helpers.get_caller_filename()
  if not vim.list_contains(M.ignore_at_treesitter, lang_name) then
    table.insert(M.ignore_at_treesitter, lang_name)
  end
end

---@type table<string, CommandProps>
local lang_commands = {
  install = {
    short = 'i',
    run = M.ensure_lang_deps,
  },
}

---@param arg_lead string
---@param cmdline string
---@return string[]
local function complete_lang_command(arg_lead, cmdline)
  if #vim.split(cmdline, '%s+') > 2 then return {} end

  local names = vim.tbl_keys(lang_commands)
  table.sort(names)
  return vim.tbl_filter(
    function(name) return vim.startswith(name, arg_lead) end,
    names
  )
end

vim.api.nvim_create_user_command('Lang', function(opts)
  local face = '--_--'
  local command_arg = opts.fargs[1]
  local lang_arg = opts.fargs[2]

  if command_arg == nil or lang_arg == nil then
    vim.notify('Not enough args\nUse :Lang <command> <language>\n' .. face)
    return
  end

  local command = helpers.find_command_in(lang_commands, command_arg)
  if command == nil then
    vim.notify('No ' .. command_arg .. ' Lang command found! ' .. face)
    return
  end

  command.run(lang_arg)
end, {
  nargs = '+',
  complete = complete_lang_command,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('lang-missing-deps', { clear = true }),
  callback = function(args)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        M.warn_missing_lang_deps(args.match, args.buf)
      end
    end)
  end,
})

return M
