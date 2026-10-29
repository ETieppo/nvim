local stub = require 'luassert.stub'
local deps_mod = require 'utils.deps_mod'
local OsNameEnum = require 'utils.enums.os_name_enum'

describe('nvim_deps', function()
  ---@type DepProps[]
  local installed_deps = {}
  local install = stub(
    deps_mod,
    'install',
    function(deps) installed_deps = deps end
  )
  require 'utils.nvim_deps'

  before_each(function() installed_deps = {} end)

  it(
    'hands the nvim deps to deps_mod with the short and long command',
    function()
      vim.cmd 'Deps i'
      local short_deps = installed_deps
      vim.cmd 'Deps install'

      assert.stub(install).was.called(2)
      assert.is_true(#short_deps > 0)
      assert.are.equal(short_deps, installed_deps)
    end
  )

  it(
    'declares brew only for linux and macos with the dir it exports',
    function()
      vim.cmd 'Deps i'
      ---@type table<OsNameEnum, string>
      local bin_dir_by_os = {}

      for _, dep in ipairs(installed_deps) do
        if dep.cmd == 'brew' then
          assert.is_table(dep.supported_os)
          for _, os_name in ipairs(dep.supported_os) do
            bin_dir_by_os[os_name] = dep.push_env_source
          end
        end
      end

      assert.are.same({
        [OsNameEnum.linux] = '/home/linuxbrew/.linuxbrew/bin',
        [OsNameEnum.macos] = '/opt/homebrew/bin',
      }, bin_dir_by_os)
    end
  )
end)
