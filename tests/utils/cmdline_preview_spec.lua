local cmdline_preview = require 'utils.cmdline_preview'

local namespace = vim.api.nvim_create_namespace 'cmdline-preview'

---@class PreviewFixtureProps
---@field source_window integer
---@field source_buffer integer
---@field cmdwin_buffer integer

---@param lines string[]
---@param cmdline_type string
---@return PreviewFixtureProps
local function open_preview(lines, cmdline_type)
  vim.cmd 'silent! only'
  local source_buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(source_buffer)
  vim.api.nvim_buf_set_lines(source_buffer, 0, -1, false, lines)
  local source_window = vim.api.nvim_get_current_win()

  vim.cmd 'new'
  local cmdwin_buffer = vim.api.nvim_get_current_buf()
  cmdline_preview.attach(cmdwin_buffer, source_window, cmdline_type)

  return {
    source_window = source_window,
    source_buffer = source_buffer,
    cmdwin_buffer = cmdwin_buffer,
  }
end

---@param fixture PreviewFixtureProps
---@param line string
local function type_line(fixture, line)
  vim.api.nvim_buf_set_lines(fixture.cmdwin_buffer, 0, -1, false, { line })
  vim.api.nvim_exec_autocmds('TextChanged', { buffer = fixture.cmdwin_buffer })
end

---@param fixture PreviewFixtureProps
---@return vim.api.keyset.get_extmark_item[]
local function get_marks(fixture)
  return vim.api.nvim_buf_get_extmarks(
    fixture.source_buffer,
    namespace,
    0,
    -1,
    { details = true }
  )
end

describe('cmdline_preview substitute', function()
  after_each(cmdline_preview.detach)

  it('renders every replacement inline and conceals the match', function()
    local fixture = open_preview({ 'foo bar foo' }, ':')
    type_line(fixture, '%s/foo/baz/g')

    local replacements = vim.tbl_map(
      function(mark) return mark[4].virt_text and mark[4].virt_text[1][1] end,
      get_marks(fixture)
    )
    assert.are.same(
      { 'baz', 'baz' },
      vim.tbl_filter(function(text) return text ~= nil end, replacements)
    )
    assert.are.equal(2, vim.wo[fixture.source_window].conceallevel)
  end)

  it('expands groups and case modifiers', function()
    local fixture = open_preview({ 'hello world' }, ':')
    type_line(fixture, [[s/\(\w\+\) \(\w\+\)/\u\2 \U\1/]])

    local mark = vim
      .iter(get_marks(fixture))
      :find(function(item) return item[4].virt_text ~= nil end)
    assert.are.equal('World HELLO', mark[4].virt_text[1][1])
  end)

  it('clears marks and restores conceal on detach', function()
    local fixture = open_preview({ 'foo' }, ':')
    local conceallevel = vim.wo[fixture.source_window].conceallevel
    type_line(fixture, 's/foo/bar/')
    cmdline_preview.detach()

    assert.are.same({}, get_marks(fixture))
    assert.are.equal(conceallevel, vim.wo[fixture.source_window].conceallevel)
  end)
end)

describe('cmdline_preview search', function()
  after_each(cmdline_preview.detach)

  it('highlights the current match', function()
    local fixture = open_preview({ 'one', 'two', 'three two' }, '/')
    type_line(fixture, 'two')

    local marks = get_marks(fixture)
    assert.are.equal(1, #marks)
    assert.are.equal('IncSearch', marks[1][4].hl_group)
    assert.are.equal(1, marks[1][2])
  end)

  it('ignores unsupported cmdline types', function()
    local fixture = open_preview({ 'two' }, '@')
    type_line(fixture, 'two')
    assert.are.same({}, get_marks(fixture))
  end)
end)
