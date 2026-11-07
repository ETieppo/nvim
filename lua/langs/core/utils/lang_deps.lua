local deps_command = require 'hooks.deps_command'
local deps_mod = require 'utils.deps_mod'
local lang_registry = require 'langs.core.utils.lang_registry'
local LangDepsResolutionDto = require 'utils.dtos.lang_deps_resolution_dto'

---@class DepsCollectorProps
---@field resolution LangDepsResolutionDto
---@field collected_deps table<DepProps, boolean>
---@field visited_references table<string, boolean>

---@class LangDepsModProps
local M = {}

---@type table<string, boolean>
local warned_langs = {}

---@param cmd string
---@return DepProps[]|nil
local function find_deps_up_to_cmd(cmd)
  for _, lang in pairs(lang_registry.get_langs()) do
    for index, dep in ipairs(lang.deps) do
      if dep.cmd == cmd then return vim.list_slice(lang.deps, 1, index) end
    end
  end
  return nil
end

---@param reference string
---@return DepProps[]|nil
local function find_referenced_deps(reference)
  local lang = lang_registry.find_lang(reference)
  if lang then return lang.deps end
  return find_deps_up_to_cmd(reference)
end

---@param reference string | string[] | nil
---@param deps DepProps[]
---@param collector DepsCollectorProps
local function collect_deps(reference, deps, collector)
  ---@type string[]
  local references = (type(reference) ~= 'string') and reference
    or { reference }

  for _, ref in ipairs(references) do
    if ref and not collector.visited_references[ref] then
      collector.visited_references[ref] = true
      local referenced_deps = find_referenced_deps(ref)
      if referenced_deps then
        collect_deps(nil, referenced_deps, collector)
      else
        table.insert(collector.resolution.unresolved_references, ref)
      end
    end
  end

  for _, dep in ipairs(deps) do
    collect_deps(dep.depends_on, {}, collector)
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

  collect_deps(lang.depends_on, lang.deps, collector)
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
  local lang = lang_registry.find_lang(name_or_short)
  if not lang then
    vim.notify('No config to install\n' .. name_or_short .. ' deps (#_#)')
    return
  end

  local resolution = M.resolve_lang_deps(lang)
  notify_unresolved_references(resolution)
  deps_mod.install(resolution.deps)
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
