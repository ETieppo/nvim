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

describe('pacman resolution', function()
  local AUR_INFO = "curl -fsS 'https://aur.archlinux.org/rpc/v5/info?arg[]=%s'"
  local AUR_PROVIDES =
    "curl -fsS 'https://aur.archlinux.org/rpc/v5/search/%s?by=provides'"
  local BREW_FORMULA =
    'curl -fsS -o /dev/null https://formulae.brew.sh/api/formula/%s.json'

  ---@param names string[]
  ---@return string
  local function aur_results(names)
    return vim.json.encode {
      results = vim.tbl_map(function(name) return { Name = name } end, names),
    }
  end

  ---@param outputs table<string, string>
  ---@return CommandOutputReaderProps
  local function reader(outputs)
    return function(command) return outputs[command] end
  end

  ---@param manager PackageManager
  ---@param package_name string
  ---@param allows_prebuilt_binaries boolean
  ---@param outputs table<string, string>
  ---@return string|nil
  local function resolved_command(
    manager,
    package_name,
    allows_prebuilt_binaries,
    outputs
  )
    local resolution =
      manager:resolve(package_name, allows_prebuilt_binaries, reader(outputs))
    return resolution
      and resolution.package_manager:build_install_command(
        resolution.package_name
      )
  end

  local pacman = PackageManager.create(
    PackageManagerNameEnum.pacman,
    executables { 'pacman', 'yay', 'brew' }
  )

  it(
    'prefers the exact pacman package',
    function()
      assert.are.equal(
        'sudo pacman -S --needed --noconfirm jdtls',
        resolved_command(pacman, 'jdtls', false, {
          ['pacman -Si jdtls'] = 'Name : jdtls',
          [AUR_INFO:format 'jdtls'] = aur_results { 'jdtls' },
        })
      )
    end
  )

  it(
    'uses the exact aur package before brew',
    function()
      assert.are.equal(
        'yay -S --needed --noconfirm --aur jdtls',
        resolved_command(pacman, 'jdtls', false, {
          [AUR_INFO:format 'jdtls'] = aur_results { 'jdtls' },
          [BREW_FORMULA:format 'jdtls'] = '',
        })
      )
    end
  )

  it(
    'uses the exact brew formula before related packages',
    function()
      assert.are.equal(
        'brew install tofu-ls',
        resolved_command(pacman, 'tofu-ls', false, {
          [AUR_INFO:format 'tofu-ls'] = aur_results {},
          [AUR_PROVIDES:format 'tofu-ls'] = aur_results { 'tofu-ls-bin' },
          [BREW_FORMULA:format 'tofu-ls'] = '',
        })
      )
    end
  )

  it('falls back to related packages after every exact lookup', function()
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm bash',
      resolved_command(pacman, 'sh', false, {
        ['pacman -Sp --print-format %n sh'] = 'bash\n',
        [AUR_PROVIDES:format 'sh'] = aur_results { 'sh-git' },
      })
    )
    assert.are.equal(
      'yay -S --needed --noconfirm --aur foo-git',
      resolved_command(pacman, 'foo', false, {
        [AUR_PROVIDES:format 'foo'] = aur_results { 'foo-bin', 'foo-git' },
      })
    )
  end)

  it(
    'never derives an aur -bin package',
    function()
      assert.is_nil(resolved_command(pacman, 'tofu-ls', false, {
        [AUR_INFO:format 'tofu-ls'] = aur_results {},
        [AUR_PROVIDES:format 'tofu-ls'] = aur_results { 'tofu-ls-bin' },
      }))
    end
  )

  it(
    'installs an aur -bin package when explicitly allowed',
    function()
      assert.are.equal(
        'yay -S --needed --noconfirm --aur tofu-ls-bin',
        resolved_command(pacman, 'tofu-ls-bin', true, {
          [AUR_INFO:format 'tofu-ls-bin'] = aur_results { 'tofu-ls-bin' },
        })
      )
    end
  )

  it('skips yay when missing and calls brew by its prefix', function()
    local without_helpers = PackageManager.create(
      PackageManagerNameEnum.pacman,
      executables { 'pacman' }
    )
    local resolution = assert(without_helpers:resolve(
      'tofu-ls',
      false,
      reader {
        [AUR_INFO:format 'tofu-ls'] = aur_results { 'tofu-ls' },
        [BREW_FORMULA:format 'tofu-ls'] = '',
      }
    ))

    assert.are.equal(
      '/home/linuxbrew/.linuxbrew/bin/brew install tofu-ls',
      resolution.package_manager:build_install_command(resolution.package_name)
    )
    assert.are.equal(
      '/home/linuxbrew/.linuxbrew/bin',
      resolution.package_manager:get_unlisted_bin_dir()
    )
    assert.are.equal(1, #resolution.package_manager:get_bootstrap_commands())
  end)
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
