---@class ByUnix
---@field unix string
---@field windows string
---@field macos? nil
---@field archlinux? nil

---@class ByOs
---@field archlinux string
---@field macos string
---@field windows string
---@field unix? nil

---@alias OsInstruction ByUnix | ByOs

---@alias DepProps { cmd: string, os: OsInstruction } | { cmd: string, install_command: string }

---@class LangDeps
---@field lang string
---@field deps DepProps[]

local M = {}
local os = require 'utils.os'

---@param lang string
function M.ensure_lang_deps(lang)
  for _, l in ipairs(M.langs) do
    if lang == l.lang then
      local commands_to_install = {}
      for _, cli in ipairs(l.deps) do
        if not os.which(cli.cmd) then
          local install_command = cli.install_command
            or (os.is_windows() and cli.os.windows)
            or cli.os.unix
            or (os.is_linux() and cli.os.archlinux)
            or (os.is_macos() and cli.os.macos)
          if install_command == nil then return end
          table.insert(commands_to_install, install_command)
        else
          vim.notify(cli.cmd .. ' command already installed')
        end
      end
      if #commands_to_install > 0 then
        os.run_in_terminal(commands_to_install)
      end
      return
    end
  end
  vim.notify('No config to install\n' .. lang .. ' deps (#_#)')
end

---@type LangDeps[]
M.langs = {
  {
    lang = 'typescript',
    deps = {
      {
        cmd = 'bun',
        os = {
          unix = 'curl -fsSL https://bun.sh/install | bash',
          windows = 'powershell -c "irm bun.sh/install.ps1|iex"',
        },
      },
      {
        cmd = 'prettierd',
        install_command = 'bun i -g @fsouza/prettierd',
      },
      {
        cmd = 'tsc',
        install_command = 'bun i -g typescript',
      },
    },
  },
  {
    lang = 'rust',
    deps = {
      {
        cmd = 'rustup',
        os = {
          unix = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh",
          windows = 'scoop install rustup',
        },
      },
      {
        cmd = 'cargo',
        install_command = 'rustup toolchain install stable',
      },
      {
        cmd = 'rust-analyzer',
        install_command = 'rustup component add rust-analyzer',
      },
    },
  },
  {
    lang = 'lua',
    deps = {
      {
        cmd = 'lua',
        os = {
          archlinux = 'pacman -S lua',
          windows = 'scoop install main/lua',
          macos = 'brew install lua',
        },
      },
      {
        cmd = 'lua-language-server',
        os = {
          macos = 'brew install lua-language-server',
          archlinux = 'pacman -S lua-language-server',
          windows = 'scoop install main/lua-language-server',
        },
      },
    },
  },
  {
    lang = 'zig',
    deps = {
      {
        cmd = 'zvm',
        os = {
          unix = 'curl https://www.zvm.app/install.sh | bash',
          windows = 'irm https://www.zvm.app/install.ps1 | iex',
        },
      },
      {
        cmd = 'zig',
        install_command = 'zvm install lts',
      },
      {
        cmd = 'zls',
        install_command = 'zvm install lts --zls',
      },
    },
  },
  {
    lang = 'go',
    deps = {
      {
        cmd = 'go',
        os = {
          macos = 'brew install go',
          windows = 'scoop install main/go',
          archlinux = 'pacman -S go',
        },
      },
      {
        cmd = 'gopls',
        os = {
          unix = 'go install golang.org/x/tools/gopls@latest && echo export PATH=$PATH:$(go env GOPATH)/bin >> ~/.zshrc',
          windows = 'go install golang.org/x/tools/gopls@latest',
        },
      },
    },
  },
}

return M
