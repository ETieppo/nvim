local dap_mod = require 'langs.core.dap_mod'
local docs_mod = require 'langs.core.docs_mod'
local fmt_mod = require 'langs.core.fmt_mod'
local lang_deps = require 'langs.core.utils.lang_deps'
local lang_registry = require 'langs.core.utils.lang_registry'
local lint_mod = require 'langs.core.lint_mod'
local lsp_mod = require 'langs.core.lsp_mod'
local test_mod = require 'langs.core.test_mod'
local treesitter_mod = require 'langs.core.treesitter_mod'
local utils_helpers = require 'utils.helpers'
local langs_path = vim.fn.stdpath 'config' .. '/lua/langs'
require 'langs.core.auto_cmd'

---@class LangCoreProps : DapModProps, DocsModProps, FmtModProps, LangDepsModProps, LangRegistryModProps, LintModProps, LspModProps, TestModProps, TreesitterModProps
local M = {}

for _, module in ipairs {
  dap_mod,
  docs_mod,
  fmt_mod,
  lang_deps,
  lang_registry,
  lint_mod,
  lsp_mod,
  test_mod,
  treesitter_mod,
} do
  ---@cast module table<string, function>
  for key, value in pairs(module) do
    M[key] = value
  end
end

function M.load_langs()
  for _, lang_name in ipairs(utils_helpers.find_lua_module_names(langs_path)) do
    ---@type vim.lsp.Config|nil
    local lsp_config = require('langs.' .. lang_name)
    lsp_mod.record_lsp_config(
      lang_registry.resolve_lsp_name(lang_name),
      lsp_config
    )
  end
end

return M
