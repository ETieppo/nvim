local deps_command = require 'deps.commands'
local deps_mod = require 'deps.deps_mod'
local lang_registry = require 'core.lang.registry'
local helpers = require 'utils.helpers'
local lsp_registry = require 'core.lsp.registry'
local dap_registry = require 'core.dap.registry'
local linter_registry = require 'core.linter.registry'
local formatter_registry = require 'core.formatter.registry'
local test_registry = require 'core.test.registry'
local LangDepsResolutionDto = require('deps.dtos').LangDepsResolutionDto

---@class DepsCollectorProps
---@field resolution LangDepsResolutionDto
---@field collected_cmds table<string, boolean>
---@field visited_references table<string, boolean>

---@class LangDepsModProps
local M = {}

---@type table<string, boolean>
local DEP_IDENTITY_FIELDS = { cmd = true, lang = true }

---@type table<string, boolean>
local warned_langs = {}

local DEPS_OWNER_REGISTRIES =
  { lsp_registry, dap_registry, linter_registry, formatter_registry }

---@param dep DepProps
---@return boolean
local function is_bare(dep)
  for field in pairs(dep) do
    if not DEP_IDENTITY_FIELDS[field] then return false end
  end
  return true
end

---@param lang RecordedLangProps
---@return DepProps[]
local function get_all_lang_deps(lang)
  local deps = vim.list_slice(lang.deps)
  for _, registry in ipairs(DEPS_OWNER_REGISTRIES) do
    vim.list_extend(deps, registry.get_deps(lang.lang))
  end
  return deps
end

---@param cmd string
---@return DepProps[]|nil
local function find_deps_up_to_cmd(cmd)
  ---@type DepProps[]|nil
  local bare_match = nil
  for _, lang in pairs(lang_registry.get_langs()) do
    for index, dep in ipairs(get_all_lang_deps(lang)) do
      if dep.cmd == cmd then
        local deps = index <= #lang.deps and vim.list_slice(lang.deps, 1, index)
          or { dep }
        if not is_bare(dep) then return deps end
        bare_match = bare_match or deps
      end
    end
  end
  return bare_match
end

---@param reference string
---@param includes_tool_deps boolean
---@return DepProps[]|nil
local function find_referenced_deps(reference, includes_tool_deps)
  local lang = lang_registry.find_lang(reference)
  if not lang then return find_deps_up_to_cmd(reference) end
  return includes_tool_deps and get_all_lang_deps(lang) or lang.deps
end

---@param references string|string[]|nil
---@param includes_tool_deps boolean
---@param deps DepProps[]
---@param collector DepsCollectorProps
local function collect_deps(references, includes_tool_deps, deps, collector)
  for _, reference in ipairs(helpers.ensure_list(references or {})) do
    ---@cast reference string
    if not collector.visited_references[reference] then
      collector.visited_references[reference] = true
      local referenced_deps =
        find_referenced_deps(reference, includes_tool_deps)
      if referenced_deps then
        collect_deps(nil, false, referenced_deps, collector)
      else
        table.insert(collector.resolution.unresolved_references, reference)
      end
    end
  end

  for _, dep in ipairs(deps) do
    if not collector.collected_cmds[dep.cmd] then
      local declared_deps = is_bare(dep) and find_deps_up_to_cmd(dep.cmd)
      if declared_deps and not is_bare(declared_deps[#declared_deps]) then
        collect_deps(nil, false, declared_deps, collector)
      else
        collect_deps(dep.depends_on, false, {}, collector)
        collector.collected_cmds[dep.cmd] = true
        table.insert(collector.resolution.deps, dep)
      end
    end
  end
end

---@param lang RecordedLangProps
---@return LangDepsResolutionDto
function M.resolve_lang_deps(lang)
  ---@type DepsCollectorProps
  local collector = {
    resolution = LangDepsResolutionDto.new(),
    collected_cmds = {},
    visited_references = { [lang.lang] = true },
  }

  collect_deps(lang.depends_on, true, get_all_lang_deps(lang), collector)
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
function M.install_lang_deps(name_or_short)
  require('core.lang.def_index').load_all_langs()
  local lang = lang_registry.find_lang(name_or_short)
  if not lang then
    vim.notify('No config to install\n' .. name_or_short .. ' deps (#_#)')
    return
  end

  local resolution = M.resolve_lang_deps(lang)
  notify_unresolved_references(resolution)
  deps_mod.install(
    resolution.deps,
    function() test_registry.enable_lang_test_adapters(lang.lang) end
  )
end

---@param filetype string
---@param buffer integer
function M.warn_missing_lang_deps(filetype, buffer)
  for _, lang in ipairs(lang_registry.find_langs_for_buffer(filetype, buffer)) do
    if not warned_langs[lang.lang] then
      warned_langs[lang.lang] = true

      local resolution = M.resolve_lang_deps(lang)
      deps_command.notify_missing_deps {
        title = 'Lang',
        subject = lang.lang,
        missing_deps = deps_mod.find_missing(resolution.deps),
        install_command = ':Lang i ' .. (lang.short or lang.lang),
      }
    end
  end
end

return M
