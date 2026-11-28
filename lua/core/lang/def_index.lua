local storage = require 'utils.storage'
local plugins = require 'deps.plugins'
local helpers = require 'utils.helpers'

---@class LangDefProps
---@field toolchain? boolean
---@field short? string
---@field lsp? string
---@field filetypes? string[]
---@field depends_on? string|string[]
---@field deps? DepProps[]
---@field treesitter? string|string[]
---@field treesitter_install? TreesitterInstallInfoProps
---@field treesitter_ignore? boolean
---@field treesitter_filetypes? string[]
---@field doc? string|string[]
---@field docs_ignore? boolean
---@field filetype_rules? vim.filetype.add.filetypes

---@class LangIndexEntryProps : LangDefProps
---@field name string
---@field modules string[]

---@class LangIndexCacheProps
---@field signature table<string, string>
---@field langs table<string, LangIndexEntryProps>

---@class LangDefIndexModProps
local M = {}

local SERVERS_MODULE = 'servers'
local SERVERS_DIRECTORY =
  vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', SERVERS_MODULE)
local CACHE_FILE =
  vim.fs.joinpath(vim.fn.stdpath 'cache', 'lang_def_index.json')
local DEF_MODULE_NAME = 'def'
local DEF_FILE_NAME = DEF_MODULE_NAME .. '.lua'
local LUA_EXTENSION = '.lua'
local FILETYPE_EVENT = 'FileType'
local CONSTANT_KEY_PATTERN = '^[%u%d_]+$'

---@type table<string, LangIndexEntryProps>|nil
local indexed_langs = nil

local is_activated = false

---@type table<string, boolean>
local loaded_langs = {}

---@type table<string, string[]>|nil
local langs_by_filetype = nil

---@param path string
---@return string|nil
local function get_modification_time(path)
  local stat = vim.uv.fs_stat(path)
  return stat and (stat.mtime.sec .. ':' .. stat.mtime.nsec)
end

---@param directory string
---@param wanted_type 'file'|'directory'
---@return string[]
local function list_entries(directory, wanted_type)
  ---@type string[]
  local names = {}
  local handle = vim.uv.fs_scandir(directory)
  while handle do
    local name, entry_type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if entry_type == wanted_type then table.insert(names, name) end
  end
  table.sort(names)
  return names
end

---@return table<string, string>
local function build_signature()
  ---@type table<string, string>
  local signature =
    { [SERVERS_DIRECTORY] = get_modification_time(SERVERS_DIRECTORY) or '' }
  for _, name in ipairs(list_entries(SERVERS_DIRECTORY, 'directory')) do
    local directory = vim.fs.joinpath(SERVERS_DIRECTORY, name)
    local def_path = vim.fs.joinpath(directory, DEF_FILE_NAME)
    local def_time = get_modification_time(def_path)
    if def_time then
      signature[directory] = get_modification_time(directory) or ''
      signature[def_path] = def_time
    end
  end
  return signature
end

---@param name string
---@return string[]
local function list_trigger_modules(name)
  ---@type string[]
  local modules = {}
  for _, file in
    ipairs(list_entries(vim.fs.joinpath(SERVERS_DIRECTORY, name), 'file'))
  do
    if
      vim.endswith(file, LUA_EXTENSION)
      and file ~= DEF_FILE_NAME
      and not plugins.is_spec_file(file)
    then
      table.insert(
        modules,
        table.concat(
          { SERVERS_MODULE, name, file:sub(1, -#LUA_EXTENSION - 1) },
          '.'
        )
      )
    end
  end
  return modules
end

---@param name string
---@return LangIndexEntryProps
local function build_entry(name)
  local def =
    require(table.concat({ SERVERS_MODULE, name, DEF_MODULE_NAME }, '.')) --[[@as LangDefProps]]
  ---@type LangIndexEntryProps
  local entry = { name = name, modules = list_trigger_modules(name) }
  for key, value in pairs(def) do
    if not key:match(CONSTANT_KEY_PATTERN) then entry[key] = value end
  end
  return entry
end

---@param signature table<string, string>
---@return table<string, LangIndexEntryProps>
local function build_langs(signature)
  ---@type table<string, LangIndexEntryProps>
  local langs = {}
  for path in pairs(signature) do
    if vim.fs.basename(path) == DEF_FILE_NAME then
      local name = vim.fs.basename(vim.fs.dirname(path))
      langs[name] = build_entry(name)
    end
  end
  return langs
end

---@param signature table<string, string>
---@return table<string, LangIndexEntryProps>|nil
local function read_cached_langs(signature)
  local cache = storage.read_json(CACHE_FILE) --[[@as LangIndexCacheProps|nil]]
  if cache and vim.deep_equal(cache.signature, signature) then
    return cache.langs
  end
  return nil
end

---@return table<string, LangIndexEntryProps>
function M.get_langs()
  if indexed_langs then return indexed_langs end

  local signature = build_signature()
  indexed_langs = read_cached_langs(signature)
  if not indexed_langs then
    indexed_langs = build_langs(signature)
    pcall(
      storage.write_json,
      CACHE_FILE,
      { signature = signature, langs = indexed_langs },
      false
    )
  end
  return indexed_langs
end

---@param name string
---@param entry LangIndexEntryProps
local function activate_lang(name, entry)
  local treesitter = require 'core.treesitter.registry'
  local lang_registry = require 'core.lang.registry'

  if entry.docs_ignore then require('core.docs.registry').docs_ignore(name) end
  if entry.treesitter_ignore then treesitter.treesitter_ignore(name) end
  if entry.treesitter_install then
    treesitter.record_treesitter(name, entry.treesitter_install)
  end
  if entry.treesitter_filetypes then
    treesitter.record_language_filetypes(name, entry.treesitter_filetypes)
  end
  if entry.filetype_rules then
    lang_registry.record_filetypes(entry.filetype_rules)
  end

  if entry.toolchain == false then
    for _, treesitter_name in
      ipairs(helpers.ensure_list(entry.treesitter or {}))
    do
      ---@cast treesitter_name string
      treesitter.record_treesitter(treesitter_name)
    end
    require('core.docs.registry').record_docs(
      helpers.ensure_list(entry.doc or {})
    )
    return
  end

  lang_registry.record_toolchain {
    lang = name,
    short = entry.short,
    lsp = entry.lsp,
    filetypes = entry.filetypes,
    depends_on = entry.depends_on,
    deps = entry.deps,
    treesitter = entry.treesitter,
    doc = entry.doc,
  }
end

function M.activate()
  if is_activated then return end
  is_activated = true
  for name, entry in pairs(M.get_langs()) do
    activate_lang(name, entry)
  end
end

---@param name string
function M.load_lang(name)
  if loaded_langs[name] then return end
  loaded_langs[name] = true
  M.activate()
  for _, module in ipairs(M.get_langs()[name].modules) do
    require(module)
  end
end

function M.load_all_langs()
  for name in pairs(M.get_langs()) do
    M.load_lang(name)
  end
end

---@return table<string, string[]>
local function get_langs_by_filetype()
  if langs_by_filetype then return langs_by_filetype end
  langs_by_filetype = {}
  for name, entry in pairs(M.get_langs()) do
    if #entry.modules > 0 then
      for _, filetype in ipairs(entry.filetypes or { name }) do
        langs_by_filetype[filetype] = langs_by_filetype[filetype] or {}
        table.insert(langs_by_filetype[filetype], name)
      end
    end
  end
  return langs_by_filetype
end

---@return table<integer, boolean>
local function get_filetype_autocmd_groups()
  ---@type table<integer, boolean>
  local groups = {}
  for _, autocmd in ipairs(vim.api.nvim_get_autocmds { event = FILETYPE_EVENT }) do
    if autocmd.group then groups[autocmd.group] = true end
  end
  return groups
end

---@param args vim.api.keyset.create_autocmd.callback_args
local function load_filetype_langs(args)
  local names = vim.tbl_filter(
    ---@param name string
    ---@return boolean
    function(name) return not loaded_langs[name] end,
    get_langs_by_filetype()[args.match] or {}
  )
  if #names == 0 then return end

  local groups_before = get_filetype_autocmd_groups()
  for _, name in ipairs(names) do
    M.load_lang(name)
  end
  for group in pairs(get_filetype_autocmd_groups()) do
    if not groups_before[group] then
      vim.api.nvim_exec_autocmds(FILETYPE_EVENT, {
        group = group,
        buffer = args.buf,
        modeline = false,
      })
    end
  end
end

function M.create_filetype_trigger()
  vim.api.nvim_create_autocmd(FILETYPE_EVENT, {
    desc = 'Load the languages of a filetype on first use',
    group = vim.api.nvim_create_augroup(
      'lang-filetype-trigger',
      { clear = true }
    ),
    callback = load_filetype_langs,
  })
end

return M
