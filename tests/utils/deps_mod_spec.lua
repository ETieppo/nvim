local deps_mod = require 'utils.deps_mod'
local Shell = require 'utils.shell'
local PackageManager = require 'utils.package_manager'
local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'
local ShellNameEnum = require 'utils.enums.shell_name_enum'

---@class FakeEnvironmentProps
---@field os_name OsNameEnum
---@field package_manager? PackageManagerNameEnum
---@field shell? ShellNameEnum
---@field executables? string[]
---@field outputs? table<string, string>
---@field confirm_install? InstallConfirmationProps

---@param props FakeEnvironmentProps
---@return InstallEnvironmentProps
local function environment(props)
  local available = props.executables or {}
  local function has_executable(name) return vim.list_contains(available, name) end

  return {
    os_name = props.os_name,
    package_manager = props.package_manager
      and PackageManager.create(props.package_manager, has_executable),
    shell = Shell.create(props.shell or ShellNameEnum.zsh),
    has_executable = has_executable,
    read_command_output = function(command)
      return (props.outputs or {})[command]
    end,
    confirm_install = props.confirm_install or function() return false end,
  }
end

---@param dep DepProps
---@param env InstallEnvironmentProps
---@return string|nil
local function command_for(dep, env)
  return deps_mod.plan({ dep }, env).commands[1]
end

local arch = environment {
  os_name = OsNameEnum.linux,
  package_manager = PackageManagerNameEnum.pacman,
  executables = { 'pacman', 'yay', 'brew' },
  outputs = {
    ['pacman -Si rustup'] = 'Name : rustup',
    ['pacman -Si taplo-cli'] = 'Name : taplo-cli',
    ['pacman -Si tree-sitter-cli'] = 'Name : tree-sitter-cli',
    ['pacman -Si qt6-languageserver'] = 'Name : qt6-languageserver',
    ['brew info --formula tofu-ls'] = 'tofu-ls: stable',
  },
}
local debian = environment {
  os_name = OsNameEnum.linux,
  package_manager = PackageManagerNameEnum.apt,
  executables = { 'apt' },
  outputs = {
    ['apt-cache show taplo-cli'] = 'Package: taplo-cli',
  },
}
local macos = environment {
  os_name = OsNameEnum.macos,
  package_manager = PackageManagerNameEnum.brew,
  executables = { 'brew' },
  outputs = {
    ['brew info --formula foo'] = 'foo: stable',
    ['brew info --formula tree-sitter'] = 'tree-sitter: stable',
    ['brew info --formula hashicorp/tap/terraform'] = 'terraform: stable',
  },
}
local windows = environment {
  os_name = OsNameEnum.windows,
  package_manager = PackageManagerNameEnum.scoop,
  shell = ShellNameEnum.pwsh,
  executables = { 'scoop' },
}

describe('deps_mod instruction selection', function()
  ---@param prompts string[]
  ---@param answer boolean
  ---@param outputs table<string, string>
  ---@return InstallEnvironmentProps
  local function arch_answering(prompts, answer, outputs)
    return environment {
      os_name = OsNameEnum.linux,
      package_manager = PackageManagerNameEnum.pacman,
      executables = { 'pacman', 'yay' },
      outputs = outputs,
      confirm_install = function(package_manager_name, package_name)
        table.insert(prompts, package_manager_name .. ' ' .. package_name)
        return answer
      end,
    }
  end

  it(
    'falls back to cmd as the package name',
    function()
      assert.are.equal(
        'sudo pacman -S --needed --noconfirm rustup',
        command_for({ cmd = 'rustup' }, arch)
      )
    end
  )

  it('uses the linux key on every linux distro', function()
    local dep = { cmd = 'taplo', os = { linux = 'taplo-cli' } }
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm taplo-cli',
      command_for(dep, arch)
    )
    assert.are.equal('sudo apt install -y taplo-cli', command_for(dep, debian))
  end)

  it('uses unix for macos and linux but not windows', function()
    local dep = { cmd = 'zvm', os = { unix = 'curl x | bash' } }
    assert.are.equal('curl x | bash', command_for(dep, macos))
    assert.are.equal('curl x | bash', command_for(dep, arch))
    assert.are.equal('scoop install zvm', command_for(dep, windows))
  end)

  it('prefers the specific os over unix', function()
    local dep = {
      cmd = 'tree-sitter',
      os = { unix = 'tree-sitter-cli', macos = 'tree-sitter' },
    }
    assert.are.equal('brew install tree-sitter', command_for(dep, macos))
    assert.are.equal(
      'sudo pacman -S --needed --noconfirm tree-sitter-cli',
      command_for(dep, arch)
    )
  end)

  it('prefers linux over unix and installs an explicit -bin', function()
    local prompts = {}
    local dep = { cmd = 'foo', os = { linux = 'foo-bin', unix = 'foo' } }
    local env = arch_answering(prompts, false, {
      ['yay -Si --aur foo-bin'] = 'Name : foo-bin',
    })

    assert.are.equal(
      'yay -S --needed --noconfirm --aur foo-bin',
      command_for(dep, env)
    )
    assert.are.same({}, prompts)
    assert.are.equal('brew install foo', command_for(dep, macos))
  end)

  it('asks before installing a -bin derived from the cmd name', function()
    local accepted_prompts, declined_prompts = {}, {}
    local outputs = { ['yay -Si --aur bar-bin'] = 'Name : bar-bin' }

    assert.are.equal(
      'yay -S --needed --noconfirm --aur bar-bin',
      command_for(
        { cmd = 'bar' },
        arch_answering(accepted_prompts, true, outputs)
      )
    )
    assert.are.same({ 'yay bar-bin' }, accepted_prompts)

    local plan = deps_mod.plan(
      { { cmd = 'bar' } },
      arch_answering(declined_prompts, false, outputs)
    )
    assert.are.same({}, plan.commands)
    assert.are.same({ 'bar' }, plan.skipped)
    assert.are.same({ 'yay bar-bin' }, declined_prompts)
  end)

  it(
    'resolves through yay and brew when pacman lacks the package',
    function()
      assert.are.equal(
        'brew install tofu-ls',
        command_for({ cmd = 'tofu-ls' }, arch)
      )
    end
  )

  it('skips deps that no manager provides', function()
    local plan = deps_mod.plan({ { cmd = 'nothing' } }, arch)
    assert.are.same({ 'nothing' }, plan.skipped)
    assert.are.same({}, plan.commands)
  end)

  it(
    'runs shell install commands verbatim',
    function()
      assert.are.equal(
        'rustup toolchain install stable',
        command_for(
          { cmd = 'cargo', install_command = 'rustup toolchain install stable' },
          windows
        )
      )
    end
  )

  it(
    'installs single tokens with the package manager',
    function()
      assert.are.equal(
        'brew install hashicorp/tap/terraform',
        command_for(
          { cmd = 'terraform', install_command = 'hashicorp/tap/terraform' },
          macos
        )
      )
    end
  )
end)

describe('deps_mod supported_os', function()
  ---@type DepProps
  local linux_only = {
    cmd = 'linux-tool',
    install_command = 'install linux-tool',
    supported_os = { OsNameEnum.linux },
  }

  it('plans a dep only on the systems it supports', function()
    assert.are.equal('install linux-tool', command_for(linux_only, arch))

    local plan = deps_mod.plan({ linux_only }, windows)
    assert.are.same({}, plan.commands)
    assert.are.same({}, plan.installed)
    assert.are.same({}, plan.skipped)
  end)

  it('never reports an unsupported dep as missing', function()
    assert.are.same({ linux_only }, deps_mod.find_missing({ linux_only }, arch))
    assert.are.same({}, deps_mod.find_missing({ linux_only }, macos))
  end)

  it('keeps deps without supported_os on every system', function()
    ---@type DepProps
    local everywhere = { cmd = 'everywhere', install_command = 'install it' }
    for _, env in ipairs { arch, macos, windows } do
      assert.are.equal('install it', command_for(everywhere, env))
    end
  end)
end)

describe('deps_mod.find_missing', function()
  local probe = environment {
    os_name = OsNameEnum.linux,
    executables = { 'java', 'gcc', 'go', 'ruby' },
    outputs = {
      ['java --version'] = 'openjdk 17.0.2 2022-01-18',
      ['go version'] = 'go version go1.22.1 linux/amd64',
      ['ruby --version'] = 'ruby 4.0.7 (2026-09-15 revision 229531a6cf)',
      ['python3 -c "import debugpy"'] = '',
    },
  }

  ---@param deps DepProps[]
  ---@return string[]
  local function missing(deps)
    return vim.tbl_map(
      function(dep) return dep.cmd end,
      deps_mod.find_missing(deps, probe)
    )
  end

  it(
    'uses check_cmd instead of executables when given',
    function()
      assert.are.same(
        { 'other' },
        missing {
          { cmd = 'debugpy', check_cmd = 'python3 -c "import debugpy"' },
          { cmd = 'other', check_cmd = 'python3 -c "import other"' },
        }
      )
    end
  )

  it(
    'detects missing executables and accepts alternatives',
    function()
      assert.are.same(
        { 'zig' },
        missing {
          { cmd = 'zig' },
          { cmd = 'cc', alternative_cmds = { 'clang', 'gcc' } },
        }
      )
    end
  )

  it('reads the version automatically from the usual flags', function()
    assert.are.same(
      { 'java' },
      missing {
        { cmd = 'java', min_version = '21' },
        { cmd = 'go', min_version = '1.20' },
        { cmd = 'ruby', min_version = '3' },
      }
    )
    assert.are.same({}, missing { { cmd = 'java', min_version = '17' } })
  end)

  it(
    'treats unreadable versions as missing',
    function()
      assert.are.same({ 'gcc' }, missing { { cmd = 'gcc', min_version = '1' } })
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
      shell = ShellNameEnum.powershell,
    }
    local plan = deps_mod.plan({ { cmd = 'rustup' } }, env)

    assert.is_true(plan.uses_package_manager)
    assert.are.same({
      'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
      'irm get.scoop.sh | iex',
      'scoop install rustup',
    }, plan.commands)
  end)

  it('bootstraps scoop again on every plan without leaking commands', function()
    local env = environment {
      os_name = OsNameEnum.windows,
      package_manager = PackageManagerNameEnum.scoop,
      shell = ShellNameEnum.powershell,
    }
    deps_mod.plan({ { cmd = 'rustup' } }, env)
    local plan = deps_mod.plan({ { cmd = 'git' } }, env)

    assert.are.same({
      'Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force',
      'irm get.scoop.sh | iex',
      'scoop install git',
    }, plan.commands)
  end)

  it('does not bootstrap when only shell commands run', function()
    local env = environment {
      os_name = OsNameEnum.windows,
      package_manager = PackageManagerNameEnum.scoop,
      shell = ShellNameEnum.powershell,
    }
    local plan =
      deps_mod.plan({ { cmd = 'kof', install_command = 'kfvm u lts' } }, env)
    assert.are.same({ 'kfvm u lts' }, plan.commands)
  end)
end)

describe('deps_mod push_env_source', function()
  local original_home = vim.env.HOME
  local home = ''

  ---@type DepProps
  local linux_brew = {
    cmd = 'brew',
    supported_os = { OsNameEnum.linux },
    push_env_source = '/home/linuxbrew/.linuxbrew/bin',
    install_command = 'install brew',
  }

  before_each(function()
    home = vim.fn.tempname()
    vim.fn.mkdir(home, 'p')
    vim.env.HOME = home
  end)

  after_each(function() vim.env.HOME = original_home end)

  it(
    'exports the path labeled by lang right after the install',
    function()
      assert.are.equal(
        [[rbenv install -s ruby && echo '\n# RUBY\nexport PATH="$PATH:$HOME/.rbenv/shims"' >> ~/.zshrc && source ~/.zshrc]],
        command_for({
          cmd = 'ruby',
          lang = 'ruby',
          install_command = 'rbenv install -s ruby',
          push_env_source = '.rbenv/shims',
        }, arch)
      )
    end
  )

  it(
    'labels by cmd without lang and keeps absolute paths',
    function()
      assert.are.equal(
        [[sudo pacman -S --needed --noconfirm qt6-languageserver && echo '\n# QMLLS6\nexport PATH="$PATH:/usr/lib/qt6/bin"' >> ~/.zshrc && source ~/.zshrc]],
        command_for({
          cmd = 'qmlls6',
          push_env_source = '/usr/lib/qt6/bin',
          os = { linux = 'qt6-languageserver' },
        }, arch)
      )
    end
  )

  it('only sources the rc when the export already exists', function()
    vim.fn.writefile({ 'export PATH="$PATH:$HOME/go/bin"' }, home .. '/.zshrc')
    assert.are.equal(
      'go install gopls && source ~/.zshrc',
      command_for({
        cmd = 'gopls',
        lang = 'go',
        install_command = 'go install gopls',
        push_env_source = 'go/bin',
      }, arch)
    )
  end)

  it('exports a shared source once per plan', function()
    local plan = deps_mod.plan({
      {
        cmd = 'a',
        install_command = 'install a',
        push_env_source = 'tools/bin',
      },
      {
        cmd = 'b',
        install_command = 'install b',
        push_env_source = 'tools/bin',
      },
    }, arch)

    assert.is_truthy(plan.commands[1]:find('>> ~/.zshrc', 1, true))
    assert.are.equal('install b && source ~/.zshrc', plan.commands[2])
  end)

  it('uses the rc of the detected shell', function()
    local bash =
      environment { os_name = OsNameEnum.linux, shell = ShellNameEnum.bash }
    assert.is_truthy(
      command_for(
        { cmd = 'x', install_command = 'install x', push_env_source = 'x/bin' },
        bash
      ):find '>> ~/.bashrc && source ~/.bashrc$'
    )
  end)

  it(
    'leaves windows commands untouched',
    function()
      assert.are.equal(
        'dotnet tool install x',
        command_for({
          cmd = 'x',
          install_command = 'dotnet tool install x',
          push_env_source = '.dotnet/tools',
        }, windows)
      )
    end
  )

  it('reports a found dep whose source is not exported in the rc', function()
    local original_path, original_shell = vim.env.PATH, vim.o.shell
    vim.o.shell = 'zsh'
    local bin = home .. '/.fake/bin'
    vim.fn.mkdir(bin, 'p')
    vim.fn.writefile({ '#!/bin/sh' }, bin .. '/fake-cli')
    vim.fn.setfperm(bin .. '/fake-cli', 'rwxr-xr-x')
    ---@type DepProps[]
    local deps =
      { { cmd = 'fake-cli', lang = 'fake', push_env_source = '.fake/bin' } }

    deps_mod.add_to_session_path(deps)
    assert.are.same(deps, deps_mod.find_missing(deps))

    vim.fn.writefile(
      { 'export PATH="$PATH:$HOME/.fake/bin"' },
      home .. '/.zshrc'
    )
    assert.are.same({}, deps_mod.find_missing(deps))
    vim.env.PATH, vim.o.shell = original_path, original_shell
  end)

  it('only exports and sources when the dep is installed', function()
    local env = environment {
      os_name = OsNameEnum.linux,
      executables = { 'ruby' },
    }
    local plan = deps_mod.plan({
      { cmd = 'ruby', lang = 'ruby', push_env_source = '.rbenv/shims' },
    }, env)

    assert.are.same({
      [[echo '\n# RUBY\nexport PATH="$PATH:$HOME/.rbenv/shims"' >> ~/.zshrc && source ~/.zshrc]],
    }, plan.commands)
    assert.are.same({}, plan.installed)
  end)

  it(
    'installs brew before exporting its bin dir when it is missing',
    function()
      assert.are.equal(
        [[install brew && echo '\n# BREW\nexport PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"' >> ~/.zshrc && source ~/.zshrc]],
        command_for(linux_brew, debian)
      )
    end
  )

  it(
    'exports and sources the rc when brew is installed but not exported',
    function()
      assert.are.equal(
        [[echo '\n# BREW\nexport PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"' >> ~/.zshrc && source ~/.zshrc]],
        command_for(linux_brew, arch)
      )
    end
  )

  it('leaves an installed and exported brew alone', function()
    vim.fn.writefile(
      { 'export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"' },
      home .. '/.zshrc'
    )
    local plan = deps_mod.plan({ linux_brew }, arch)

    assert.are.same({}, plan.commands)
    assert.are.same({ 'brew' }, plan.installed)
  end)

  it('adds existing sources to the session path', function()
    local original_path = vim.env.PATH
    vim.fn.mkdir(home .. '/.rbenv/shims', 'p')

    deps_mod.add_to_session_path {
      { cmd = 'ruby', push_env_source = '.rbenv/shims' },
      { cmd = 'missing', push_env_source = '.missing/bin' },
    }

    assert.is_true(vim.startswith(vim.env.PATH, home .. '/.rbenv/shims:'))
    assert.is_falsy(vim.env.PATH:find('.missing/bin', 1, true))
    vim.env.PATH = original_path
  end)
end)

describe('deps_mod release', function()
  local original_data_home, original_path = vim.env.XDG_DATA_HOME, vim.env.PATH
  local root = ''

  ---@type DepProps
  local wrapped = {
    cmd = 'fake-adapter',
    release = {
      repo = 'owner/repo',
      asset_pattern = 'fake-[^"]+\\.tar\\.gz',
      wrapper = { runtime = 'bun', entry = 'src/server.js' },
    },
  }

  ---@type DepProps
  local native = {
    cmd = 'native-adapter',
    release = {
      repo = 'owner/native',
      asset_pattern = 'adapter\\.zip',
      bin_subdir = 'adapter/bin',
    },
  }

  before_each(function()
    root = vim.fn.tempname()
    vim.env.XDG_DATA_HOME = root .. '/data'
  end)

  after_each(function()
    vim.env.XDG_DATA_HOME = original_data_home
    vim.env.PATH = original_path
  end)

  it('downloads the latest matching asset of the repo on unix only', function()
    local command = assert(command_for(wrapped, arch))
    assert.is_truthy(
      command:find('api.github.com/repos/owner/repo/releases/latest', 1, true)
    )
    assert.is_truthy(command:find('fake-[^"]+\\.tar\\.gz', 1, true))
    assert.is_falsy(command_for(native, arch):find('printf', 1, true))
    assert.are.equal(
      'scoop install fake-adapter',
      command_for(wrapped, windows)
    )
  end)

  it('installs and wraps the asset in a real shell', function()
    local fake_bin, source = root .. '/bin', root .. '/source'
    vim.fn.mkdir(fake_bin, 'p')
    vim.fn.mkdir(source .. '/src', 'p')
    vim.fn.writefile({ 'server' }, source .. '/src/server.js')
    vim
      .system({ 'tar', '-czf', root .. '/asset.tar.gz', '-C', source, 'src' })
      :wait()
    vim.fn.writefile({
      '#!/bin/sh',
      'case "$*" in',
      '  *api.github.com*) echo \'"url": "https://example.com/fake-v1.tar.gz"\' ;;',
      '  *) cp "$FAKE_ASSET" "$3" ;;',
      'esac',
    }, fake_bin .. '/curl')
    vim.fn.setfperm(fake_bin .. '/curl', 'rwxr-xr-x')

    local result = vim
      .system({ 'sh', '-c', assert(command_for(wrapped, arch)) }, {
        text = true,
        env = {
          PATH = fake_bin .. ':' .. original_path,
          FAKE_ASSET = root .. '/asset.tar.gz',
        },
      })
      :wait()

    local install_dir = root .. '/data/nvim/debug-adapters/fake-adapter'
    local wrapper = install_dir .. '/bin/fake-adapter'
    assert.are.equal(0, result.code, result.stderr)
    assert.are.equal(1, vim.fn.executable(wrapper))
    assert.are.same({
      '#!/bin/sh',
      'exec bun "' .. install_dir .. '/src/server.js" "$@"',
    }, vim.fn.readfile(wrapper))

    deps_mod.add_to_session_path { wrapped, native }
    assert.is_true(vim.startswith(vim.env.PATH, install_dir .. '/bin:'))
    assert.is_falsy(vim.env.PATH:find('native-adapter', 1, true))
  end)
end)
