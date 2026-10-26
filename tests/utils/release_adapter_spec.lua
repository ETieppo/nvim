local ReleaseAdapter = require 'utils.release_adapter'
local ArchiveFormatEnum = require 'utils.enums.archive_format_enum'

local install_root = vim.fn.tempname()

local wrapped = ReleaseAdapter.new {
  name = 'fake-adapter',
  repo = 'owner/repo',
  asset_pattern = 'fake-[^"]+\\.tar\\.gz',
  archive_format = ArchiveFormatEnum.tar_gz,
  wrapper = { runtime = 'bun', entry = 'src/server.js' },
  install_root = install_root,
}

local native = ReleaseAdapter.new {
  name = 'native-adapter',
  repo = 'owner/native',
  asset_pattern = 'adapter\\.zip',
  archive_format = ArchiveFormatEnum.zip,
  bin_subdir = 'adapter/bin',
  install_root = install_root,
}

describe('ReleaseAdapter paths', function()
  it('uses bin by default and the given bin_subdir otherwise', function()
    assert.are.equal(install_root .. '/fake-adapter/bin', wrapped:get_bin_dir())
    assert.are.equal(
      install_root .. '/native-adapter/adapter/bin',
      native:get_bin_dir()
    )
  end)

  it('adds the bin dir to PATH once', function()
    local original_path = vim.env.PATH
    assert.is_true(native:add_to_path())
    assert.is_false(native:add_to_path())
    vim.env.PATH = original_path
  end)
end)

describe('ReleaseAdapter:build_install_command', function()
  it('downloads the latest matching asset of the repo', function()
    local command = wrapped:build_install_command()
    assert.is_truthy(
      command:find('api.github.com/repos/owner/repo/releases/latest', 1, true)
    )
    assert.is_truthy(command:find('fake-[^"]+\\.tar\\.gz', 1, true))
    assert.is_truthy(command:find('tar -xzf', 1, true))
  end)

  it('uses unzip for zip archives and skips the wrapper', function()
    local command = native:build_install_command()
    assert.is_truthy(command:find('unzip -q', 1, true))
    assert.is_falsy(command:find('printf', 1, true))
  end)

  it('writes an executable wrapper that runs the entry', function()
    local dir = install_root .. '/fake-adapter'
    local script = 'dir=' .. vim.fn.shellescape(dir)
    for _, step in ipairs(wrapped:build_wrapper_steps()) do
      script = script .. ' && ' .. step
    end

    local result = vim.system({ 'sh', '-c', script }, { text = true }):wait()
    local wrapper = dir .. '/bin/fake-adapter'

    assert.are.equal(0, result.code)
    assert.are.equal(1, vim.fn.executable(wrapper))
    assert.are.same({
      '#!/bin/sh',
      'exec bun "' .. dir .. '/src/server.js" "$@"',
    }, vim.fn.readfile(wrapper))
  end)
end)
