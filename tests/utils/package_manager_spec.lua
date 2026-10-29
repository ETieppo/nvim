local PackageManager = require 'utils.package_manager'
local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'

---@class ConfirmationRecorderProps
---@field prompts string[]
---@field confirm_install InstallConfirmationProps

---@param available string[]
---@return fun(name: string): boolean
local function executables(available)
  return function(name) return vim.list_contains(available, name) end
end

---@param outputs table<string, string>
---@return CommandOutputReaderProps
local function reader(outputs)
  return function(command) return outputs[command] end
end

---@return boolean
local function decline_install() return false end

---@param answer boolean
---@return ConfirmationRecorderProps
local function confirmation(answer)
  local prompts = {}
  return {
    prompts = prompts,
    confirm_install = function(package_manager_name, package_name)
      table.insert(prompts, package_manager_name .. ' ' .. package_name)
      return answer
    end,
  }
end

---@param manager PackageManager
---@return PackageManagerNameEnum[]
local function chain_of(manager)
  return vim.tbl_map(
    function(source) return source.name end,
    manager.resolution_sources
  )
end

---@param manager PackageManager
---@param package_name string
---@param outputs table<string, string>
---@param confirm_install? InstallConfirmationProps
---@return string|nil
local function resolved_command(manager, package_name, outputs, confirm_install)
  local resolution = manager:resolve(
    package_name,
    reader(outputs),
    confirm_install or decline_install
  )
  return resolution
    and resolution.package_manager:build_install_command(
      resolution.package_name
    )
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

describe('PackageManager.create', function()
  it(
    'chains pacman to yay and brew',
    function()
      assert.are.same(
        {
          PackageManagerNameEnum.pacman,
          PackageManagerNameEnum.yay,
          PackageManagerNameEnum.brew,
        },
        chain_of(
          PackageManager.create(
            PackageManagerNameEnum.pacman,
            executables { 'pacman', 'yay', 'brew' }
          )
        )
      )
    end
  )

  it('leaves fallbacks that are not installed out of the chain', function()
    assert.are.same(
      { PackageManagerNameEnum.pacman },
      chain_of(
        PackageManager.create(
          PackageManagerNameEnum.pacman,
          executables { 'pacman' }
        )
      )
    )
    assert.are.same(
      { PackageManagerNameEnum.pacman, PackageManagerNameEnum.brew },
      chain_of(
        PackageManager.create(
          PackageManagerNameEnum.pacman,
          executables { 'pacman', 'brew' }
        )
      )
    )
  end)

  it('chains every other linux package manager to brew', function()
    for _, name in ipairs {
      PackageManagerNameEnum.apt,
      PackageManagerNameEnum.dnf,
      PackageManagerNameEnum.zypper,
      PackageManagerNameEnum.apk,
    } do
      assert.are.same(
        { name, PackageManagerNameEnum.brew },
        chain_of(PackageManager.create(name, executables { name, 'brew' }))
      )
    end
  end)

  it('gives brew and scoop no fallbacks', function()
    assert.are.same(
      { PackageManagerNameEnum.brew },
      chain_of(
        PackageManager.create(
          PackageManagerNameEnum.brew,
          executables { 'brew', 'yay' }
        )
      )
    )
    assert.are.same(
      { PackageManagerNameEnum.scoop },
      chain_of(
        PackageManager.create(
          PackageManagerNameEnum.scoop,
          executables { 'scoop', 'brew' }
        )
      )
    )
  end)
end)

describe('PackageManager:has_package', function()
  it('queries each package manager with its own listing command', function()
    ---@type table<PackageManagerNameEnum, string>
    local expected_queries = {
      [PackageManagerNameEnum.pacman] = 'pacman -Si foo',
      [PackageManagerNameEnum.yay] = 'yay -Si --aur foo',
      [PackageManagerNameEnum.apt] = 'apt-cache show foo',
      [PackageManagerNameEnum.dnf] = 'dnf info -q foo',
      [PackageManagerNameEnum.zypper] = 'zypper --non-interactive search --match-exact foo',
      [PackageManagerNameEnum.apk] = 'apk search -x foo',
      [PackageManagerNameEnum.brew] = 'brew info --formula foo',
    }

    for name, expected_query in pairs(expected_queries) do
      local queries = {}
      PackageManager.create(name, executables { name })
        :has_package(
          'foo',
          function(command) table.insert(queries, command) end
        )
      assert.are.same({ expected_query }, queries)
    end
  end)

  it('treats a failed or empty listing as a missing package', function()
    local apk =
      PackageManager.create(PackageManagerNameEnum.apk, executables { 'apk' })
    assert.is_false(apk:has_package('foo', reader {}))
    assert.is_false(
      apk:has_package('foo', reader { ['apk search -x foo'] = '\n' })
    )
    assert.is_true(
      apk:has_package('foo', reader { ['apk search -x foo'] = 'foo-1.0-r0\n' })
    )
  end)

  it('accepts the package when the manager has no listing command', function()
    local queries = {}
    local scoop = PackageManager.create(
      PackageManagerNameEnum.scoop,
      executables { 'scoop' }
    )
    assert.is_true(
      scoop:has_package(
        'git',
        function(command) table.insert(queries, command) end
      )
    )
    assert.are.same({}, queries)
  end)
end)

describe('PackageManager:resolve', function()
  local arch = PackageManager.create(
    PackageManagerNameEnum.pacman,
    executables { 'pacman', 'yay', 'brew' }
  )

  it(
    'prefers the exact package of the native package manager',
    function()
      assert.are.equal(
        'sudo pacman -S --needed --noconfirm jdtls',
        resolved_command(arch, 'jdtls', {
          ['pacman -Si jdtls'] = 'Name : jdtls',
          ['yay -Si --aur jdtls'] = 'Name : jdtls',
          ['brew info --formula jdtls'] = 'jdtls: stable',
        })
      )
    end
  )

  it(
    'looks for the exact package in yay before brew',
    function()
      assert.are.equal(
        'yay -S --needed --noconfirm --aur jdtls',
        resolved_command(arch, 'jdtls', {
          ['yay -Si --aur jdtls'] = 'Name : jdtls',
          ['brew info --formula jdtls'] = 'jdtls: stable',
        })
      )
    end
  )

  it(
    'uses the exact brew formula when pacman and yay lack it',
    function()
      assert.are.equal(
        'brew install tofu-ls',
        resolved_command(arch, 'tofu-ls', {
          ['brew info --formula tofu-ls'] = 'tofu-ls: stable',
        })
      )
    end
  )

  it(
    'prefers an exact package in any manager over a -git variant',
    function()
      assert.are.equal(
        'brew install foo',
        resolved_command(arch, 'foo', {
          ['yay -Si --aur foo-git'] = 'Name : foo-git',
          ['brew info --formula foo'] = 'foo: stable',
        })
      )
    end
  )

  it('falls back to -git variants before -bin ones', function()
    local recorder = confirmation(true)
    assert.are.equal(
      'yay -S --needed --noconfirm --aur foo-git',
      resolved_command(arch, 'foo', {
        ['yay -Si --aur foo-git'] = 'Name : foo-git',
        ['yay -Si --aur foo-bin'] = 'Name : foo-bin',
      }, recorder.confirm_install)
    )
    assert.are.same({}, recorder.prompts)
  end)

  it('asks before installing a derived -bin package', function()
    local recorder = confirmation(true)
    assert.are.equal(
      'yay -S --needed --noconfirm --aur foo-bin',
      resolved_command(arch, 'foo', {
        ['yay -Si --aur foo-bin'] = 'Name : foo-bin',
      }, recorder.confirm_install)
    )
    assert.are.same({ 'yay foo-bin' }, recorder.prompts)
  end)

  it('keeps looking after a declined -bin package', function()
    local recorder = confirmation(false)
    assert.is_nil(resolved_command(arch, 'foo', {
      ['yay -Si --aur foo-bin'] = 'Name : foo-bin',
      ['brew info --formula foo-bin'] = 'foo-bin: stable',
    }, recorder.confirm_install))
    assert.are.same({ 'yay foo-bin', 'brew foo-bin' }, recorder.prompts)
  end)

  it('installs an explicitly named -bin package without asking', function()
    local recorder = confirmation(false)
    assert.are.equal(
      'yay -S --needed --noconfirm --aur tofu-ls-bin',
      resolved_command(arch, 'tofu-ls-bin', {
        ['yay -Si --aur tofu-ls-bin'] = 'Name : tofu-ls-bin',
      }, recorder.confirm_install)
    )
    assert.are.same({}, recorder.prompts)
  end)

  it(
    'returns nil when no manager has the package or a variant of it',
    function() assert.is_nil(resolved_command(arch, 'nothing', {})) end
  )
end)

describe('generic package managers', function()
  it('uses sudo for apt', function()
    local apt =
      PackageManager.create(PackageManagerNameEnum.apt, executables { 'apt' })
    assert.are.equal('sudo apt install -y git', apt:build_install_command 'git')
  end)

  it('does not use sudo for brew', function()
    local brew =
      PackageManager.create(PackageManagerNameEnum.brew, executables { 'brew' })
    assert.are.equal('brew install git', brew:build_install_command 'git')
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
      scoop:build_install_command 'java/openjdk'
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
