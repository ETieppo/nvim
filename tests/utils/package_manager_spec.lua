local PackageManager = require 'utils.package_manager'
local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'

---@param available string[]
---@return fun(name: string): boolean
local function executables(available)
  return function(name) return vim.list_contains(available, name) end
end

describe('PackageManager.detect', function()
  it('prefers pacman over other linux package managers', function()
    local manager = assert(
      PackageManager.detect(OsNameEnum.linux, executables { 'apt', 'pacman' })
    )
    assert.are.equal(PackageManagerNameEnum.pacman, manager.name)
  end)

  it(
    'returns nil when no package manager exists',
    function()
      assert.is_nil(PackageManager.detect(OsNameEnum.macos, executables {}))
    end
  )

  it('always returns scoop on windows', function()
    local manager =
      assert(PackageManager.detect(OsNameEnum.windows, executables {}))
    assert.are.equal(PackageManagerNameEnum.scoop, manager.name)
    assert.is_false(manager.is_available)
  end)
end)

describe('pacman', function()
  it('falls back to yay without sudo when pacman fails', function()
    local pacman = PackageManager.create(
      PackageManagerNameEnum.pacman,
      executables { 'pacman', 'yay' }
    )
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm jdtls'
        .. ' || yay -S --needed --noconfirm jdtls',
      pacman:build_install_command { 'jdtls' }
    )
  end)

  it('uses only pacman when yay is missing', function()
    local pacman = PackageManager.create(
      PackageManagerNameEnum.pacman,
      executables { 'pacman' }
    )
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm rbenv ruby-build',
      pacman:build_install_command { 'rbenv', 'ruby-build' }
    )
  end)
end)

describe('generic package managers', function()
  it('uses sudo for apt', function()
    local apt =
      PackageManager.create(PackageManagerNameEnum.apt, executables { 'apt' })
    assert.are.equal(
      'sudo apt install -y git',
      apt:build_install_command { 'git' }
    )
  end)

  it('does not use sudo for brew', function()
    local brew =
      PackageManager.create(PackageManagerNameEnum.brew, executables { 'brew' })
    assert.are.equal('brew install git', brew:build_install_command { 'git' })
  end)
end)

describe('scoop', function()
  it('adds buckets before installing bucketed packages', function()
    local scoop = PackageManager.create(
      PackageManagerNameEnum.scoop,
      executables { 'scoop' }
    )
    assert.are.equal(
      'scoop bucket add java ; scoop install java/openjdk',
      scoop:build_install_command { 'java/openjdk' }
    )
  end)

  it('bootstraps itself only when unavailable', function()
    local missing =
      PackageManager.create(PackageManagerNameEnum.scoop, executables {})
    local available = PackageManager.create(
      PackageManagerNameEnum.scoop,
      executables { 'scoop' }
    )
    assert.are.equal(2, #missing:get_bootstrap_commands())
    assert.are.same({}, available:get_bootstrap_commands())
  end)
end)
