local os_mod = require 'utils.os_mod'
local OsNameEnum = require 'utils.enums.os_name_enum'

describe('os_mod.join_commands', function()
  it(
    'groups each unix command so a fallback cannot leak',
    function()
      assert.are.equal(
        '{ false; } && { sudo pacman -S a || yay -S a; } && { echo done; }',
        os_mod.join_commands(
          { 'false', 'sudo pacman -S a || yay -S a', 'echo done' },
          OsNameEnum.linux
        )
      )
    end
  )

  it('stops on the first failed group in a real shell', function()
    local script = os_mod.join_commands(
      { 'false', 'true || echo leaked', 'echo leaked' },
      OsNameEnum.linux
    )
    local result = vim.system({ 'sh', '-c', script }, { text = true }):wait()
    assert.are_not.equal(0, result.code)
    assert.are.equal('', result.stdout)
  end)

  it('keeps exported variables between groups', function()
    local script = os_mod.join_commands(
      { 'export SHARED_VALUE=kept', 'printf "$SHARED_VALUE"' },
      OsNameEnum.linux
    )
    local result = vim.system({ 'sh', '-c', script }, { text = true }):wait()
    assert.are.equal('kept', result.stdout)
  end)

  it(
    'sequences windows commands with semicolons',
    function()
      assert.are.equal(
        'a ; b',
        os_mod.join_commands({ 'a', 'b' }, OsNameEnum.windows)
      )
    end
  )
end)

describe('os_mod paths', function()
  it(
    'normalizes backslashes',
    function() assert.are.equal('a/b/c', os_mod.normalize_os_path 'a\\b\\c') end
  )
end)

describe('os_mod.which', function()
  it('finds existing executables and caches misses', function()
    assert.is_true(os_mod.has_executable 'sh')
    assert.is_nil(os_mod.which 'definitely-not-an-executable-name')
    os_mod.clear_cache()
    assert.is_false(os_mod.has_executable 'definitely-not-an-executable-name')
  end)
end)

describe('os_mod.add_to_path', function()
  local original_path = vim.env.PATH

  after_each(function() vim.env.PATH = original_path end)

  it('prepends an existing directory only once', function()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')

    assert.is_true(os_mod.add_to_path(dir))
    assert.is_false(os_mod.add_to_path(dir))
    assert.is_true(vim.startswith(vim.env.PATH, dir .. ':'))
    assert.are.equal(original_path, vim.env.PATH:sub(#dir + 2))
  end)

  it('ignores missing directories', function()
    assert.is_false(os_mod.add_to_path '/definitely/not/a/real/dir')
    assert.are.equal(original_path, vim.env.PATH)
  end)
end)
