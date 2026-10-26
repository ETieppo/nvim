local deps_mod = require 'utils.deps_mod'
local package_managers = require 'utils.package_managers'
local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'
local InstallStrategyEnum = require 'utils.enums.install_strategy_enum'

---@class FakeEnvironmentProps
---@field os_name OsNameEnum
---@field package_manager? PackageManagerNameEnum
---@field executables? string[]
---@field outputs? table<string, string>

---@param props FakeEnvironmentProps
---@return InstallEnvironmentProps
local function environment(props)
  local available = props.executables or {}
  local function has_executable(name) return vim.list_contains(available, name) end

  return {
    os_name = props.os_name,
    package_manager = props.package_manager
      and package_managers.create(props.package_manager, has_executable),
    has_executable = has_executable,
    read_command_output = function(command)
      return (props.outputs or {})[command]
    end,
  }
end

local arch = environment {
  os_name = OsNameEnum.linux,
  package_manager = PackageManagerNameEnum.pacman,
  executables = { 'pacman', 'yay' },
}
local debian = environment {
  os_name = OsNameEnum.linux,
  package_manager = PackageManagerNameEnum.apt,
  executables = { 'apt' },
}
local macos = environment {
  os_name = OsNameEnum.macos,
  package_manager = PackageManagerNameEnum.brew,
  executables = { 'brew' },
}
local windows = environment {
  os_name = OsNameEnum.windows,
  package_manager = PackageManagerNameEnum.scoop,
  executables = { 'scoop' },
}

describe('deps_mod.classify', function()
  it('treats single tokens as packages', function()
    assert.are.equal(InstallStrategyEnum.package, deps_mod.classify 'rustup')
    assert.are.equal(InstallStrategyEnum.package, deps_mod.classify 'main/llvm')
    assert.are.equal(
      InstallStrategyEnum.package,
      deps_mod.classify 'hashicorp/tap/terraform'
    )
  end)

  it('treats commands with spaces or shell operators as shell', function()
    assert.are.equal(InstallStrategyEnum.shell, deps_mod.classify 'kfvm u lts')
    assert.are.equal(
      InstallStrategyEnum.shell,
      deps_mod.classify 'curl -fsSL https://bun.sh/install|bash'
    )
  end)
end)

describe('deps_mod.select_instruction', function()
  it(
    'falls back to cmd as the package name',
    function()
      assert.are.equal(
        'rustup',
        deps_mod.select_instruction({ cmd = 'rustup' }, arch)
      )
    end
  )

  it('uses archlinux only with pacman', function()
    local dep = { cmd = 'taplo', os = { archlinux = 'taplo-cli' } }
    assert.are.equal('taplo-cli', deps_mod.select_instruction(dep, arch))
    assert.are.equal('taplo', deps_mod.select_instruction(dep, debian))
  end)

  it('uses unix for macos and linux but not windows', function()
    local dep = { cmd = 'zvm', os = { unix = 'curl x | bash' } }
    assert.are.equal('curl x | bash', deps_mod.select_instruction(dep, macos))
    assert.are.equal('curl x | bash', deps_mod.select_instruction(dep, arch))
    assert.are.equal('zvm', deps_mod.select_instruction(dep, windows))
  end)

  it('prefers the specific os over unix', function()
    local dep = {
      cmd = 'tree-sitter',
      os = { unix = 'tree-sitter-cli', macos = 'tree-sitter' },
    }
    assert.are.equal('tree-sitter', deps_mod.select_instruction(dep, macos))
    assert.are.equal('tree-sitter-cli', deps_mod.select_instruction(dep, arch))
  end)

  it('uses install_command when no os key matches', function()
    local dep =
      { cmd = 'cargo', install_command = 'rustup toolchain install stable' }
    assert.are.equal(
      'rustup toolchain install stable',
      deps_mod.select_instruction(dep, windows)
    )
  end)

  it('falls back to cmd when the current os has no key', function()
    local dep = { cmd = 'swipl', os = { archlinux = 'sudo pacman -S x' } }
    assert.are.equal('swipl', deps_mod.select_instruction(dep, macos))
  end)
end)

describe('deps_mod.build_install_command', function()
  it('installs packages with the system package manager', function()
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm rustup || yay -S --needed --noconfirm rustup',
      deps_mod.build_install_command({ cmd = 'rustup' }, arch)
    )
    assert.are.equal(
      'sudo apt install -y rustup',
      deps_mod.build_install_command({ cmd = 'rustup' }, debian)
    )
    assert.are.equal(
      'brew install rustup',
      deps_mod.build_install_command({ cmd = 'rustup' }, macos)
    )
    assert.are.equal(
      'scoop install rustup',
      deps_mod.build_install_command({ cmd = 'rustup' }, windows)
    )
  end)

  it('runs shell instructions verbatim', function()
    local command, strategy = deps_mod.build_install_command(
      { cmd = 'kof', install_command = 'kfvm u lts' },
      arch
    )
    assert.are.equal('kfvm u lts', command)
    assert.are.equal(InstallStrategyEnum.shell, strategy)
  end)

  it('returns nil for packages without a package manager', function()
    local bare = environment { os_name = OsNameEnum.macos }
    assert.is_nil(deps_mod.build_install_command({ cmd = 'git' }, bare))
  end)
end)

describe('deps_mod.is_installed', function()
  local probe = environment {
    os_name = OsNameEnum.linux,
    executables = { 'java', 'gcc' },
    outputs = { ['java --version'] = 'openjdk 17.0.2 2022-01-18' },
  }

  it(
    'detects missing executables',
    function() assert.is_false(deps_mod.is_installed({ cmd = 'zig' }, probe)) end
  )

  it(
    'accepts alternative executables',
    function()
      assert.is_true(
        deps_mod.is_installed(
          { cmd = 'cc', alternative_cmds = { 'clang', 'gcc' } },
          probe
        )
      )
    end
  )

  it('requires the minimum version', function()
    assert.is_false(
      deps_mod.is_installed({ cmd = 'java', min_version = '21' }, probe)
    )
    assert.is_true(
      deps_mod.is_installed({ cmd = 'java', min_version = '17' }, probe)
    )
  end)

  it(
    'treats unreadable versions as not installed',
    function()
      assert.is_false(
        deps_mod.is_installed(
          { cmd = 'gcc', min_version = '1', version_cmd = 'boom' },
          probe
        )
      )
    end
  )
end)

describe('deps_mod.plan', function()
  it('splits installed, skipped and commands', function()
    local env = environment {
      os_name = OsNameEnum.macos,
      executables = { 'git' },
    }
    local plan = deps_mod.plan({
      { cmd = 'git' },
      { cmd = 'rustup' },
      { cmd = 'kof', install_command = 'kfvm u lts' },
    }, env)

    assert.are.same({ 'git' }, plan.installed)
    assert.are.same({ 'rustup' }, plan.skipped)
    assert.is_false(plan.uses_package_manager)
    assert.are.same({ 'kfvm u lts' }, plan.commands)
  end)

  it('bootstraps scoop before package installs', function()
    local env = environment {
      os_name = OsNameEnum.windows,
      package_manager = PackageManagerNameEnum.scoop,
    }
    local plan = deps_mod.plan({ { cmd = 'rustup' } }, env)

    assert.is_true(plan.uses_package_manager)
    assert.are.same({
      'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
      'irm get.scoop.sh | iex',
      'scoop install rustup',
    }, plan.commands)
  end)

  it('does not bootstrap when only shell commands run', function()
    local env = environment {
      os_name = OsNameEnum.windows,
      package_manager = PackageManagerNameEnum.scoop,
    }
    local plan =
      deps_mod.plan({ { cmd = 'kof', install_command = 'kfvm u lts' } }, env)
    assert.are.same({ 'kfvm u lts' }, plan.commands)
  end)
end)
