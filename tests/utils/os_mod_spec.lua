local os_mod = require 'utils.os_mod'

describe('os_mod paths', function()
  it(
    'normalizes backslashes',
    function() assert.are.equal('a/b/c', os_mod.normalize_os_path 'a\\b\\c') end
  )

  it('treats tilde, dot and bare paths as home relative', function()
    assert.are.equal(
      '.rbenv/shims',
      os_mod.get_home_relative_path '~/.rbenv/shims'
    )
    assert.are.equal('go/bin', os_mod.get_home_relative_path './go/bin')
    assert.are.equal('go/bin', os_mod.get_home_relative_path 'go/bin')
    assert.is_nil(os_mod.get_home_relative_path '/usr/lib/qt6/bin')
  end)

  it('expands home relative paths and keeps absolute ones', function()
    local home = vim.uv.os_homedir()
    assert.are.equal(home .. '/go/bin', os_mod.expand_home_path 'go/bin')
    assert.are.equal('/opt/tool/bin', os_mod.expand_home_path '/opt/tool/bin')
  end)
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
