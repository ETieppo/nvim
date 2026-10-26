local lang_mod = require 'utils.lang_mod'
local dap_mod = require 'utils.dap_mod'
local os_mod = require 'utils.os_mod'
local lang_name = require('utils.helpers').get_this_filename()

lang_mod.record_test_adapter {
  'mrcjkb/rustaceanvim',
  module = 'rustaceanvim.neotest',
}

lang_mod.record_fmt {
  formatter = 'rustfmt',
}

lang_mod.record_lang_deps {
  short = 'rs',
  deps = {
    { cmd = 'rustup' },
    {
      cmd = 'cargo',
      install_command = 'rustup toolchain install stable',
    },
    {
      cmd = 'rust-analyzer',
      install_command = 'rustup component add rust-analyzer',
    },
  },
}

---@return string|table
local function find_cargo_executable()
  local cargo = os_mod.which 'cargo'
  local root = vim.fn.getcwd()

  if not cargo or vim.fn.filereadable(root .. '/Cargo.toml') == 0 then
    return dap_mod.ask_executable()
  end

  local build = vim.system({ cargo, 'build' }, { text = true }):wait()
  if build.code ~= 0 then
    vim.notify(
      'cargo build failed:\n' .. (build.stderr or ''),
      vim.log.levels.ERROR,
      { title = 'DAP' }
    )
    return require('dap').ABORT
  end

  local metadata = vim
    .system(
      { cargo, 'metadata', '--no-deps', '--format-version', '1' },
      { text = true }
    )
    :wait()
  if metadata.code ~= 0 then return dap_mod.ask_executable() end

  local ok, decoded = pcall(vim.json.decode, metadata.stdout)
  if not ok then return dap_mod.ask_executable() end

  for _, package in ipairs(decoded.packages or {}) do
    for _, target in ipairs(package.targets or {}) do
      if vim.list_contains(target.kind or {}, 'bin') then
        local path = root .. '/target/debug/' .. target.name
        if vim.fn.executable(path) == 1 then return path end
      end
    end
  end

  return dap_mod.ask_executable()
end

---@return string[]
local function build_lldb_init_commands()
  local rustc = os_mod.which 'rustc'
  if not rustc then return {} end

  local sysroot = vim
    .system({ rustc, '--print', 'sysroot' }, { text = true })
    :wait()
  if sysroot.code ~= 0 then return {} end

  local etc = vim.trim(sysroot.stdout) .. '/lib/rustlib/etc'
  if vim.fn.isdirectory(etc) == 0 then return {} end

  return {
    ("command script import '%s/lldb_lookup.py'"):format(etc),
    ("command source -s 0 '%s/lldb_commands'"):format(etc),
  }
end

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = {
    {
      name = 'Debug (cargo)',
      type = 'lldb',
      request = 'launch',
      program = find_cargo_executable,
      cwd = '${workspaceFolder}',
      args = {},
      stopOnEntry = false,
      initCommands = build_lldb_init_commands,
    },
  },
}

lang_mod.record_docs { docs = { 'rust' } }

return {
  cmd = { vim.fn.expand 'rust-analyzer' },
  filetypes = { lang_name },
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = true,
      check = {
        command = 'check',
      },
      procMacro = {
        enable = true,
      },
      cargo = {
        buildScripts = { enable = true },
        targetDir = true,
      },
      diagnostics = {
        enable = true,
      },
    },
  },
}
