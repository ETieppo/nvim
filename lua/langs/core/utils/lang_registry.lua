local deps_mod = require 'utils.deps_mod'
local docs_mod = require 'langs.core.docs_mod'
local treesitter_mod = require 'langs.core.treesitter_mod'
local utils_helpers = require 'utils.helpers'

---@class LangDepsProps
---@field lang? string
---@field short? string
---@field depends_on? string | string[]
---@field deps DepProps[]
---@field treesitter? string|string[]
---@field doc? string|string[]
---@field lsp? string

---@class RecordedLangProps : LangDepsProps
---@field lang string
---@field lsp string

local M = {}

---@type table<string, RecordedLangProps>
local recorded_langs = {}

---@param lang LangDepsProps
function M.record_lang_deps(lang)
  local lang_name = lang.lang or utils_helpers.get_caller_filename()

  docs_mod.record_docs(utils_helpers.ensure_list(lang.doc or lang_name))

  for _, treesitter_name in
    ipairs(utils_helpers.ensure_list(lang.treesitter or lang_name))
  do
    treesitter_mod.record_treesitter(treesitter_name)
  end

  for _, dep in ipairs(lang.deps) do
    dep.lang = dep.lang or lang_name
  end

  deps_mod.add_to_session_path(lang.deps)
  recorded_langs[lang_name] = {
    lang = lang_name,
    short = lang.short,
    depends_on = lang.depends_on,
    deps = lang.deps,
    treesitter = lang.treesitter,
    lsp = lang.lsp or lang_name,
  }
end

---@return table<string, RecordedLangProps>
function M.get_langs() return vim.tbl_extend('force', {}, recorded_langs) end

---@param name_or_short string
---@return RecordedLangProps|nil
function M.find_lang(name_or_short)
  return utils_helpers.find_by_name_or_short(recorded_langs, name_or_short)
end

---@param lang_name string
---@return string
function M.resolve_lsp_name(lang_name)
  local lang = recorded_langs[lang_name]
  return lang and lang.lsp or lang_name
end

---@param lang RecordedLangProps
---@param buffer integer
---@return boolean
local function is_buffer_inside_lang_workspace(lang, buffer)
  local lsp_config = vim.lsp.config[lang.lsp]
  if not lsp_config or not lsp_config.workspace_required then return true end
  return vim.fs.root(buffer, lsp_config.root_markers or {}) ~= nil
end

---@param lang RecordedLangProps
---@return string[]
local function get_lang_filetypes(lang)
  local lsp_config = vim.lsp.config[lang.lsp]
  return lsp_config and lsp_config.filetypes or { lang.lang }
end

---@param filetype string
---@param buffer integer
---@return RecordedLangProps[]
function M.find_langs_for_buffer(filetype, buffer)
  return vim.tbl_filter(
    function(lang)
      return vim.list_contains(get_lang_filetypes(lang), filetype)
        and is_buffer_inside_lang_workspace(lang, buffer)
    end,
    vim.tbl_values(recorded_langs)
  )
end

return M
