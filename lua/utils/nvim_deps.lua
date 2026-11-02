local deps_mod = require 'utils.deps_mod'
local deps_command = require 'hooks.deps_command'
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
  { cmd = 'pandoc' },
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

deps_mod.add_to_session_path(nvim_deps)

deps_command.create_deps_user_command {
  name = dep_user_command_name,
  desc = 'Install minimal needed dependencies X_X',
  subcommands = {
    install = {
      short = 'i',
      run = function() deps_mod.install(nvim_deps) end,
    },
  },
}

vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local missing_deps = deps_mod.find_missing(nvim_deps)
    vim.schedule(
      function()
        deps_command.notify_missing_deps {
          title = 'Neovim setup',
          subject = 'Neovim',
          missing_deps = missing_deps,
          install_command = ':' .. dep_user_command_name .. ' i',
        }
      end
    )
  end,
})

return M
