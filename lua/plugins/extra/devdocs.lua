local plugins = require 'deps.plugins'

---@class LatestDocProps
---@field slug string
---@field version number[]

plugins.record {
  'maskudo/devdocs.nvim',
  cmd = { 'DevDocs' },
  keys = {
    {
      '<leader>dds',
      mode = 'n',
      '<cmd>DevDocs get<cr>',
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
      function()
        local devdocs = require 'devdocs'
        local installed = devdocs.GetInstalledDocs()
        vim.ui.select(
          installed,
          { prompt = 'Grep em qual doc?' },
          function(selected)
            if not selected then return end
            local doc_dir = devdocs.GetDocDir(selected)
            require('telescope.builtin').live_grep { cwd = doc_dir }
          end
        )
      end,
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

    local wanted = require('langs.core').get_docs()
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
