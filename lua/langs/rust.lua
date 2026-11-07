local lang_mod = require 'langs.core'
local os_mod = require 'utils.os_mod'
local lang_name = require('utils.helpers').get_this_filename()

---@class CargoTargetProps
---@field name string
---@field kind? string[]

---@class CargoPackageProps
---@field targets? CargoTargetProps[]

---@class CargoMetadataProps
---@field packages? CargoPackageProps[]

lang_mod.record_test_adapter {
  'mrcjkb/rustaceanvim',
  module = 'rustaceanvim.neotest',
}

lang_mod.record_fmt {
  formatter = 'rustfmt',
}

lang_mod.record_lang_deps {
  short = 'rs',
  lsp = 'rust-analyzer',
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

---@return string|table|nil
local function build_cargo_debug_program()
  local cargo = os_mod.which 'cargo'
  local root = vim.fn.getcwd()
  if not cargo or vim.fn.filereadable(root .. '/Cargo.toml') == 0 then
    return nil
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

  local metadata = os_mod.read_program_stdout {
    cargo,
    'metadata',
    '--no-deps',
    '--format-version',
    '1',
  }
  if not metadata then return nil end

  local is_valid_json, cargo_metadata = pcall(vim.json.decode, metadata)
  if not is_valid_json then return nil end
  ---@cast cargo_metadata CargoMetadataProps

  for _, package in ipairs(cargo_metadata.packages or {}) do
    for _, target in ipairs(package.targets or {}) do
      if vim.list_contains(target.kind or {}, 'bin') then
        local path = root .. '/target/debug/' .. target.name
        if vim.fn.executable(path) == 1 then return path end
      end
    end
  end

  return nil
end

---@return string[]
local function build_rust_pretty_printer_commands()
  local rustc = os_mod.which 'rustc'
  if not rustc then return {} end

  local sysroot = os_mod.read_program_stdout { rustc, '--print', 'sysroot' }
  if not sysroot then return {} end

  local etc = vim.trim(sysroot) .. '/lib/rustlib/etc'
  if vim.fn.isdirectory(etc) == 0 then return {} end

  return {
    ("command script import '%s/lldb_lookup.py'"):format(etc),
    ("command source -s 0 '%s/lldb_commands'"):format(etc),
  }
end

lang_mod.record_dap {
  adapter = 'lldb',
  configurations = {
    lang_mod.build_lldb_launch_configuration {
      name = 'Debug (cargo)',
      program = lang_mod.create_program_with_prompt_fallback(
        build_cargo_debug_program
      ),
      initCommands = build_rust_pretty_printer_commands,
    },
  },
}

---@type vim.lsp.Config
return {
  cmd = { vim.fn.expand 'rust-analyzer' },
  filetypes = { lang_name },
  root_markers = {
    'Cargo.toml',
    '.git',
  },
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
