---@class NvimDeps
---@field name string
---@field bin? string
---@field required boolean
---@field check? fun(): boolean
---@field install? table<string, string[]>
---@field os_override? table<string, string[]>
---@field fallback? string[]

---@type NvimDeps[]
return {
  {
    name = 'git',
    bin = 'git',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'git' },
      apt = { 'install', '-y', 'git' },
      dnf = { 'install', '-y', 'git' },
      zypper = { 'install', '-y', 'git' },
      apk = { 'add', 'git' },
      brew = { 'install', 'git' },
      scoop = { 'install', 'git' },
    },
  },
  {
    name = 'ripgrep (rg)',
    bin = 'rg',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'ripgrep' },
      apt = { 'install', '-y', 'ripgrep' },
      dnf = { 'install', '-y', 'ripgrep' },
      zypper = { 'install', '-y', 'ripgrep' },
      apk = { 'add', 'ripgrep' },
      brew = { 'install', 'ripgrep' },
      scoop = { 'install', 'ripgrep' },
    },
  },
  {
    name = 'fd',
    bin = 'fd',
    required = false,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'fd' },
      apt = { 'install', '-y', 'fd-find' },
      dnf = { 'install', '-y', 'fd-find' },
      zypper = { 'install', '-y', 'fd' },
      apk = { 'add', 'fd' },
      brew = { 'install', 'fd' },
      scoop = { 'install', 'fd' },
    },
  },
  {
    name = 'C compiler',
    required = true,
    check = function()
      return vim.fn.executable 'cc' == 1
        or vim.fn.executable 'gcc' == 1
        or vim.fn.executable 'clang' == 1
    end,
    os_override = { mac = { 'xcode-select', '--install' } },
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'gcc' },
      apt = { 'install', '-y', 'build-essential' },
      dnf = { 'install', '-y', 'gcc' },
      zypper = { 'install', '-y', 'gcc' },
      apk = { 'add', 'build-base' },
      scoop = { 'install', 'gcc' },
    },
  },
  {
    name = 'tree-sitter-cli',
    bin = 'tree-sitter',
    required = true,
    install = {
      pacman = { '-S', '--needed', '--noconfirm', 'tree-sitter-cli' },
      dnf = { 'install', '-y', 'tree-sitter-cli' },
      brew = { 'install', 'tree-sitter' },
      scoop = { 'install', 'tree-sitter' },
    },
    fallback = { 'cargo', 'install', 'tree-sitter-cli' },
  },
}
