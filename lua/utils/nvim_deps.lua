local deps_mod = require 'utils.deps_mod'
local helpers = require 'utils.helpers'
local OsNameEnum = require 'utils.enums.os_name_enum'

local M = {}

---@type string
local dep_user_command_name = 'Deps'

---@type DepProps[]
local nvim_deps = {
  {
    cmd = 'brew',
    supported_os = { OsNameEnum.linux },
    push_env_source = '/home/linuxbrew/.linuxbrew/bin',
    install_command = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
  },
  {
    cmd = 'brew',
    supported_os = { OsNameEnum.macos },
    push_env_source = '/opt/homebrew/bin',
    install_command = '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
  },
  { cmd = 'git' },
  { cmd = 'rg', install_command = 'ripgrep' },
  { cmd = 'fd' },
  {
    cmd = 'cc',
    alternative_cmds = { 'gcc', 'clang' },
    install_command = 'gcc',
    os = { macos = 'xcode-select --install' },
  },
  {
    cmd = 'tree-sitter',
    os = { unix = 'tree-sitter-cli', macos = 'tree-sitter' },
  },
  {
    cmd = 'lldb-dap',
    install_command = 'llvm',
    os = { unix = 'lldb', macos = 'llvm' },
  },
}

local nvim_deps_commands = {
  install = {
    short = 'i',
    run = deps_mod.install,
  },
}

deps_mod.add_to_session_path(nvim_deps)

vim.api.nvim_create_user_command(dep_user_command_name, function(opts)
  local face = '--_--'
  local command_arg = opts.args

  if command_arg == nil then
    vim.notify('Not enough args\nUse :Deps <command> <language>\n' .. face)
    return
  end

  local command = helpers.find_command_in(nvim_deps_commands, command_arg)
  if command == nil then
    vim.notify(
      'No '
        .. command_arg
        .. ' '
        .. dep_user_command_name
        .. ' command found! '
        .. face
    )
    return
  end

  command.run(nvim_deps)
end, {
  nargs = 1,
  desc = 'Install minimal needed dependencies X_X',
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local missing = deps_mod.find_missing(nvim_deps)
    if #missing == 0 then return end

    local names = vim.tbl_map(function(dep) return dep.cmd end, missing)
    vim.schedule(
      function()
        vim.notify(
          'Some deps could not be find ()_()\n'
            .. table.concat(names, ',\n')
            .. '\nRun :'
            .. dep_user_command_name
            .. ' i to install ;)',
          vim.log.levels.WARN,
          { title = 'Neovim setup' }
        )
      end
    )
  end,
})

return M
