local deps_mod = require 'deps.deps_mod'
local deps_command = require 'deps.commands'
local os_mod = require 'deps.sys'
local profile = require 'deps.profile'
local OsNameEnum = require('deps.enums').OsNameEnum
local lang_deps = require 'deps.language'

local DEPS_USER_COMMAND_NAME = 'Deps'
local HOMEBREW_INSTALL_COMMAND =
  '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'

---@type table<string, table<string, string>>
local SOLOIST_ARCHIVE_BY_OS_AND_MACHINE = {
  [OsNameEnum.linux] = {
    aarch64 = 'arm64',
    armv7l = 'arm32',
    x86_64 = 'x86_64',
  },
  [OsNameEnum.macos] = { arm64 = 'osx_arm64' },
}

---@type DepProps[]
local nvim_deps = {
  {
    cmd = 'brew',
    supported_os = {
      OsNameEnum.linux,
      OsNameEnum.macos,
    },
    push_to_path = {
      linux = '/home/linuxbrew/.linuxbrew/bin',
      macos = '/opt/homebrew/bin',
    },
    install_command = HOMEBREW_INSTALL_COMMAND,
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
  {
    cmd = 'pixterm',
    depends_on = 'go',
    push_env = 'export GOPATH="$HOME/.go"',
    push_to_path = '.go/bin',
    install_command = 'go install github.com/eliukblau/pixterm/cmd/pixterm@latest',
  },
}

---@type RecordedLangProps
local nvim_lang = {
  lang = 'nvim',
  lsp = 'nvim',
  deps = nvim_deps,
}

if profile.is_max_profile() then
  local archives = SOLOIST_ARCHIVE_BY_OS_AND_MACHINE[os_mod.get_name() or '']
  local archive = archives and archives[vim.uv.os_uname().machine]
  if not archive then return {} end

  vim.list_extend(nvim_deps, {
    { cmd = 'pandoc' },
    {
      cmd = 'soloist',
      install_command = table
        .concat({
          'dir=$(mktemp -d)',
          'curl -fsSL -o "$dir/soloist.tar.gz" %s',
          'tar -xzf "$dir/soloist.tar.gz" -C "$dir"',
          'mkdir -p "$HOME/.local/bin"',
          'install -m 755 "$dir/soloist" "$HOME/.local/bin/soloist"',
          'rm -rf "$dir"',
        }, ' && ')
        :format(
          ('https://soloist-builds.spotifycdn.com/soloist_release_%s.tar.gz'):format(
            archive
          )
        ),
    },
    {
      cmd = 'soloist_mpris_adapter',
      depends_on = 'cargo',
      supported_os = {
        OsNameEnum.linux,
        OsNameEnum.macos,
      },
      install_command = ('cargo install --locked --git https://github.com/etieppo/%s --root "$HOME/.local"'):format 'soloist_mpris_adapter',
    },
  })
end

deps_mod.add_to_session_path(nvim_deps)

deps_command.create_deps_user_command {
  name = DEPS_USER_COMMAND_NAME,
  desc = 'Install minimal needed dependencies X_X',
  subcommands = {
    install = {
      short = 'i',
      run = function()
        deps_mod.install(lang_deps.resolve_lang_deps(nvim_lang).deps)
      end,
    },
  },
}

vim.api.nvim_create_autocmd('User', {
  pattern = 'VeryLazy',
  once = true,
  callback = function()
    local missing_deps =
      deps_mod.find_missing(lang_deps.resolve_lang_deps(nvim_lang).deps)
    vim.schedule(
      function()
        deps_command.notify_missing_deps {
          title = 'Neovim setup',
          subject = 'Neovim',
          missing_deps = missing_deps,
          install_command = ':' .. DEPS_USER_COMMAND_NAME .. ' i',
        }
      end
    )
  end,
})
