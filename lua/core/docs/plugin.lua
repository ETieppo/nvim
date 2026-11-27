local plugins = require 'deps.plugins'

---@param doc string
---@return Picker.Source
local function doc_files(doc)
  local devdocs = require 'devdocs'
  local doc_dir = devdocs.GetDocDir(doc)
  return {
    prompt = ('Select Doc (%s)'):format(doc),
    items = devdocs.GetDoc(doc) or {},
    format = function(file_path)
      return require('utils.helpers').format_filename_as_title(
        file_path,
        doc_dir
      )
    end,
  }
end

local function search_doc()
  local picker = require 'buffer.telescope.picker'
  picker:find {
    prompt = 'Select Language',
    items = require('devdocs').GetInstalledDocs(),
    steps = { doc_files, picker.find, picker.readonly },
  }
end

local function grep_doc()
  local picker = require 'buffer.telescope.picker'
  picker:find {
    prompt = 'Select Language',
    items = require('devdocs').GetInstalledDocs(),
    steps = { require('devdocs').GetDocDir, picker.grep, picker.readonly },
  }
end

---@class LatestDocProps
---@field slug string
---@field version number[]

plugins.record {
  'maskudo/devdocs.nvim',
  extra = true,
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>dds',
      mode = 'n',
      search_doc,
      desc = '[D]ev [D]ocs [S]earch',
    },
    {
      '<leader>ddi',
      mode = 'n',
      '<cmd>DevDocs install<cr>',
      desc = '[D]ev [D]ocs [I]nstall',
    },
    {
      '<leader>ddd',
      mode = 'n',
      '<cmd>DevDocs delete<cr>',
      desc = '[D]ev [D]ocs [D]elete',
    },
    {
      '<leader>ddg',
      mode = 'n',
      grep_doc,
      desc = '[D]ev [D]ocs [G]rep',
    },
  },
  opts = function()
    local function version_of(slug)
      ---@type number[]
      local parts = {}
      for number in (slug:match '~(.+)$' or ''):gmatch '%d+' do
        parts[#parts + 1] = tonumber(number)
      end
      return parts
    end

    local function is_newer(a, b)
      for i = 1, math.max(#a, #b) do
        local x, y = a[i] or 0, b[i] or 0
        if x ~= y then return x > y end
      end
      return false
    end

    local wanted = require('core.docs.registry').get_docs()
    ---@type table<string, boolean>
    local pending = {}
    for _, name in ipairs(wanted) do
      if not name:find('~', 1, true) then pending[name] = true end
    end

    if next(pending) == nil then return { ensure_installed = wanted } end

    ---@type table<string, LatestDocProps>
    local latest = {}
    for _, doc in ipairs(require('devdocs').GetAllDocs()) do
      local slug = doc.slug
      local base = slug:match '^[^~]+'
      if pending[base] then
        local version = version_of(slug)
        local current = latest[base]
        if not current or is_newer(version, current.version) then
          latest[base] = { slug = slug, version = version }
        end
      end
    end

    ---@type string[]
    local ensure_installed = {}
    for i, name in ipairs(wanted) do
      ensure_installed[i] = latest[name] and latest[name].slug or name
    end

    return { ensure_installed = ensure_installed }
  end,
}
