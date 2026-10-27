local Shell = require 'utils.shell'
local os_mod = require 'utils.os_mod'
local OsNameEnum = require 'utils.enums.os_name_enum'
local ShellNameEnum = require 'utils.enums.shell_name_enum'

---@param available string[]
---@return fun(name: string): boolean
local function executables(available)
  return function(name) return vim.list_contains(available, name) end
end

---@param script string
---@return vim.SystemCompleted
local function run_posix(script)
  return vim.system({ 'sh', '-c', script }, { text = true }):wait()
end

describe('Shell.detect', function()
  it('uses the configured zsh or bash on unix', function()
    assert.are.equal(
      ShellNameEnum.zsh,
      Shell.detect(OsNameEnum.linux, '/usr/bin/zsh', executables {}).name
    )
    assert.are.equal(
      ShellNameEnum.bash,
      Shell.detect(OsNameEnum.macos, '/bin/bash', executables {}).name
    )
  end)

  it('falls back to sh for unknown unix shells', function()
    local shell =
      Shell.detect(OsNameEnum.linux, '/usr/bin/fish', executables {})
    assert.are.equal(ShellNameEnum.sh, shell.name)
    assert.are.equal('~/.profile', shell.rc_file)
  end)

  it('prefers pwsh on windows and has no rc file', function()
    local pwsh =
      Shell.detect(OsNameEnum.windows, 'cmd.exe', executables { 'pwsh' })
    local powershell =
      Shell.detect(OsNameEnum.windows, 'cmd.exe', executables {})
    assert.are.equal(ShellNameEnum.pwsh, pwsh.name)
    assert.are.equal(ShellNameEnum.powershell, powershell.name)
    assert.is_nil(powershell.rc_file)
  end)
end)

describe('Shell:join', function()
  local zsh = Shell.create(ShellNameEnum.zsh)

  it(
    'groups each unix command so a fallback cannot leak',
    function()
      assert.are.equal(
        '{ false; } && { sudo pacman -S a || yay -S a; } && { echo done; }',
        zsh:join { 'false', 'sudo pacman -S a || yay -S a', 'echo done' }
      )
    end
  )

  it('stops on the first failed group in a real shell', function()
    local result =
      run_posix(zsh:join { 'false', 'true || echo leaked', 'echo leaked' })
    assert.is_true(result.code ~= 0)
    assert.are.equal('', result.stdout)
  end)

  it('keeps exported variables between groups', function()
    local result = run_posix(
      zsh:join { 'export SHARED_VALUE=kept', 'printf "$SHARED_VALUE"' }
    )
    assert.are.equal('kept', result.stdout)
  end)

  it(
    'sequences powershell commands with semicolons',
    function()
      assert.are.equal(
        'a ; b',
        Shell.create(ShellNameEnum.powershell):join { 'a', 'b' }
      )
    end
  )

  it('builds the argv for the shell', function()
    assert.are.same({ 'zsh', '-c', 'echo' }, zsh:build_argv 'echo')
    assert.are.same(
      'pwsh',
      Shell.create(ShellNameEnum.pwsh):build_argv('echo')[1]
    )
  end)
end)

describe('Shell env source', function()
  local original_home = vim.env.HOME
  local home = ''
  local zsh = Shell.create(ShellNameEnum.zsh)

  before_each(function()
    home = vim.fn.tempname()
    vim.fn.mkdir(home, 'p')
    vim.env.HOME = home
  end)

  after_each(function() vim.env.HOME = original_home end)

  it(
    'exports home relative sources through $HOME and sources the rc',
    function()
      assert.are.equal(
        [[go install x && echo '\n# GO\nexport PATH="$PATH:$HOME/go/bin"' >> ~/.zshrc && source ~/.zshrc]],
        zsh:append_env_source('go install x', 'go/bin', 'GO', true)
      )
    end
  )

  it('keeps absolute sources and only sources when already exported', function()
    assert.are.equal(
      [[x && echo '\n# QML\nexport PATH="$PATH:/usr/lib/qt6/bin"' >> ~/.zshrc && source ~/.zshrc]],
      zsh:append_env_source('x', '/usr/lib/qt6/bin', 'QML', true)
    )
    assert.are.equal(
      'x && source ~/.zshrc',
      zsh:append_env_source('x', '~/.rbenv/shims', 'RUBY', false)
    )
  end)

  it('finds exports written with any home reference', function()
    assert.is_false(zsh:has_path_export '.rbenv/shims')

    vim.fn.writefile(
      { 'export PATH="$PATH:$HOME/.rbenv/shims"' },
      home .. '/.zshrc'
    )
    assert.is_true(zsh:has_path_export '.rbenv/shims')
    assert.is_true(zsh:has_path_export '~/.rbenv/shims')
    assert.is_false(zsh:has_path_export '/usr/lib/qt6/bin')

    vim.fn.writefile(
      { 'export PATH="' .. home .. '/go/bin:$PATH"' },
      home .. '/.zshrc'
    )
    assert.is_true(zsh:has_path_export 'go/bin')
  end)

  it(
    'uses printf for shells whose echo does not expand escapes',
    function()
      assert.are.equal(
        [[x && printf '\n# GO\nexport PATH="$PATH:$HOME/go/bin"\n' >> ~/.bashrc && source ~/.bashrc]],
        Shell.create(ShellNameEnum.bash)
          :append_env_source('x', 'go/bin', 'GO', true)
      )
    end
  )

  it('writes the same block from zsh and sh', function()
    for _, name in ipairs { ShellNameEnum.zsh, ShellNameEnum.sh } do
      local shell = Shell.create(name)
      local rc_file = os_mod.expand_home_path(shell.rc_file)
      local command = shell:append_env_source('true', '.fake/bin', 'FAKE', true)
      local script = command:match '^(.*) && %S+ %S+$'
      local result = vim.system({ name, '-c', script }, { text = true }):wait()

      assert.are.equal(0, result.code, result.stderr)
      assert.are.same(
        { '', '# FAKE', 'export PATH="$PATH:$HOME/.fake/bin"' },
        vim.fn.readfile(rc_file)
      )
      assert.is_true(shell:has_path_export '.fake/bin')
    end
  end)
end)
