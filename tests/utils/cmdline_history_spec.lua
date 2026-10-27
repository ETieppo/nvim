local cmdline_history = require 'utils.cmdline_history'

---@param lines string[]
---@return integer
local function open_history_buffer(lines)
  local buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { #lines, #lines[#lines] })
  cmdline_history.attach(buffer)
  return buffer
end

describe('cmdline_history.matches_prefix', function()
  local original_ignorecase, original_smartcase =
    vim.o.ignorecase, vim.o.smartcase

  after_each(function()
    vim.o.ignorecase, vim.o.smartcase = original_ignorecase, original_smartcase
  end)

  it('follows ignorecase and smartcase', function()
    vim.o.ignorecase, vim.o.smartcase = true, true
    assert.is_true(cmdline_history.matches_prefix('Lang x y', 'l'))
    assert.is_false(cmdline_history.matches_prefix('lazy', 'La'))

    vim.o.ignorecase = false
    assert.is_false(cmdline_history.matches_prefix('Lang x y', 'l'))
  end)
end)

describe('cmdline_history.find_match', function()
  before_each(function()
    vim.o.ignorecase, vim.o.smartcase = true, true
  end)

  local lines = { 'Lang x y', 'w', 'q', 'l' }

  it('finds the newest entry with the prefix above the start', function()
    assert.are.equal(1, cmdline_history.find_match(lines, 4, 'l', 4, -1))
    assert.is_nil(cmdline_history.find_match(lines, 4, 'Q', 4, -1))
    assert.are.equal(1, cmdline_history.find_match(lines, 4, 'La', 4, -1))
  end)

  it('skips the editing row', function()
    assert.are.equal(3, cmdline_history.find_match(lines, 4, '', 4, -1))
    assert.is_nil(cmdline_history.find_match(lines, 4, '', 3, 1))
  end)
end)

describe('cmdline_history.navigate', function()
  before_each(function()
    vim.o.ignorecase, vim.o.smartcase = true, true
  end)

  it('recalls entries matching the typed prefix', function()
    open_history_buffer { 'Lang x y', 'Lazy', 'q', 'la' }

    cmdline_history.navigate(-1)
    assert.are.equal('Lazy', vim.api.nvim_get_current_line())

    cmdline_history.navigate(-1)
    assert.are.equal('Lang x y', vim.api.nvim_get_current_line())

    cmdline_history.navigate(-1)
    assert.are.equal('Lang x y', vim.api.nvim_get_current_line())
  end)

  it('restores the typed text when moving past the newest entry', function()
    open_history_buffer { 'Lang x y', 'q', 'La' }

    cmdline_history.navigate(-1)
    cmdline_history.navigate(1)
    assert.are.equal('La', vim.api.nvim_get_current_line())
  end)

  it('starts a new search after the text is edited', function()
    open_history_buffer { 'Lang x y', 'quit', 'La' }

    cmdline_history.navigate(-1)
    vim.api.nvim_set_current_line 'q'
    cmdline_history.navigate(-1)
    assert.are.equal('quit', vim.api.nvim_get_current_line())
  end)

  it('maps arrows in insert mode and arrows plus jk in normal mode', function()
    local buffer = open_history_buffer { 'Lang x y', 'q', 'L' }

    ---@param mode string
    ---@return string[]
    local function mapped_keys(mode)
      return vim.tbl_map(
        function(map) return map.lhs end,
        vim.api.nvim_buf_get_keymap(buffer, mode)
      )
    end

    local insert_keys, normal_keys = mapped_keys 'i', mapped_keys 'n'
    for _, key in ipairs { '<Up>', '<Down>' } do
      assert.is_true(vim.list_contains(insert_keys, key))
    end
    for _, key in ipairs { '<Up>', '<Down>', 'k', 'j' } do
      assert.is_true(vim.list_contains(normal_keys, key))
    end
  end)

  it('navigates with k and j in normal mode', function()
    open_history_buffer { 'Lang x y', 'Lazy', 'q', 'la' }

    vim.cmd.normal 'k'
    assert.are.equal('Lazy', vim.api.nvim_get_current_line())

    vim.cmd.normal '2k'
    assert.are.equal('Lang x y', vim.api.nvim_get_current_line())

    vim.cmd.normal 'j'
    assert.are.equal('Lazy', vim.api.nvim_get_current_line())
  end)
end)
