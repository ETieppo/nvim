local profile = require 'deps.profile'
local plugins = require 'deps.plugins'
local helpers = require 'utils.helpers'
local storage = require 'utils.storage'

---@class TestAdapterProps
---@field [1] string
---@field module string
---@field opts? table

---@class RecordedTestAdapterProps : TestAdapterProps
---@field lang string

---@class TestModProps
local M = {}

local INSTALLED_LANGS_STATE_FILE =
  vim.fs.joinpath(vim.fn.stdpath 'state', 'installed_langs.json')

---@type RecordedTestAdapterProps[]
local recorded_test_adapters = {}

---@type string[]|nil
local installed_langs = nil

---@return string[]
local function get_installed_langs()
  if installed_langs == nil then
    installed_langs = storage.read_json(INSTALLED_LANGS_STATE_FILE) or {}
  end
  return installed_langs
end

---@param lang_name string
---@return boolean
local function is_lang_installed(lang_name)
  return vim.list_contains(get_installed_langs(), lang_name)
end

---@param test_adapter TestAdapterProps
function M.record_test_adapter(test_adapter)
  if not profile.is_max_profile() then return end

  local lang_name = helpers.get_caller_directory_name()
  table.insert(
    recorded_test_adapters,
    vim.tbl_extend('force', test_adapter, { lang = lang_name })
  )
  plugins.record {
    test_adapter[1],
    lazy = true,
    cond = function() return is_lang_installed(lang_name) end,
  }
end

---@param lang_name string
function M.enable_lang_test_adapters(lang_name)
  if is_lang_installed(lang_name) then return end

  table.insert(get_installed_langs(), lang_name)
  storage.write_json(INSTALLED_LANGS_STATE_FILE, get_installed_langs(), false)

  local has_test_adapters = vim.iter(recorded_test_adapters):any(
    ---@param test_adapter RecordedTestAdapterProps
    ---@return boolean
    function(test_adapter) return test_adapter.lang == lang_name end
  )
  if
    has_test_adapters
    and helpers.confirm(
      'Restart to install the ' .. lang_name .. ' test adapter?',
      true
    )
  then
    helpers.save_and_restart()
  end
end

---@return RecordedTestAdapterProps[]
function M.get_test_adapters()
  return vim.tbl_filter(
    ---@param test_adapter RecordedTestAdapterProps
    ---@return boolean
    function(test_adapter) return is_lang_installed(test_adapter.lang) end,
    vim.deepcopy(recorded_test_adapters)
  )
end

return M
