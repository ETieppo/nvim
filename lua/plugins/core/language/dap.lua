---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    {
      '<leader>da',
      function() require('dap').continue() end,
      desc = '[D]ebugger [A]ttach',
    },
    {
      '<leader>dk',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
      desc = '[D]ebugger [K]ill',
    },
    {
      '<leader>dsi',
      function() require('dap').step_into() end,
      desc = '[D]ebug [S]tep [I]nto',
    },
    {
      '<leader>dsj',
      function() require('dap').step_over() end,
      desc = '[D]ebug [S]tep over',
    },
    {
      '<leader>dso',
      function() require('dap').step_out() end,
      desc = '[D]ebug [S]tep [O]ut',
    },
    {
      '<leader>bt',
      function() require('dap').toggle_breakpoint() end,
      desc = 'Toggle Breakpoint',
    },
    {
      '<leader>bT',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Conditional Breakpoint',
    },
    {
      '<leader>dsr',
      function() require('dapui').toggle() end,
      desc = 'Toggle DAP UI',
    },
  },
  config = function()
    local dap = require 'dap'
    local which = require('utils.os').which

    ---@return string
    local function ask_executable()
      return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
    end

    ---@return string
    local function cargo_executable()
      local cargo = which 'cargo'
      local root = vim.fn.getcwd()

      if not cargo or vim.fn.filereadable(root .. '/Cargo.toml') == 0 then
        return ask_executable()
      end

      local build = vim.system({ cargo, 'build' }, { text = true }):wait()
      if build.code ~= 0 then
        vim.notify(
          'cargo build failed:\n' .. (build.stderr or ''),
          vim.log.levels.ERROR,
          { title = 'DAP' }
        )
        return dap.ABORT
      end

      local meta = vim
        .system(
          { cargo, 'metadata', '--no-deps', '--format-version', '1' },
          { text = true }
        )
        :wait()
      if meta.code ~= 0 then return ask_executable() end

      local ok, decoded = pcall(vim.json.decode, meta.stdout)
      if not ok then return ask_executable() end

      for _, pkg in ipairs(decoded.packages or {}) do
        for _, target in ipairs(pkg.targets or {}) do
          if vim.tbl_contains(target.kind or {}, 'bin') then
            local path = root .. '/target/debug/' .. target.name
            if vim.fn.executable(path) == 1 then return path end
          end
        end
      end

      return ask_executable()
    end

    ---@return string[]
    local function rust_formatters()
      local rustc = which 'rustc'
      if not rustc then return {} end

      local sysroot =
        vim.system({ rustc, '--print', 'sysroot' }, { text = true }):wait()
      if sysroot.code ~= 0 then return {} end

      local etc = vim.trim(sysroot.stdout) .. '/lib/rustlib/etc'
      if vim.fn.isdirectory(etc) == 0 then return {} end

      return {
        ("command script import '%s/lldb_lookup.py'"):format(etc),
        ("command source -s 0 '%s/lldb_commands'"):format(etc),
      }
    end


    local adapters = {
      lldb = {
        bin = 'lldb-dap',
        make = function(cmd)
          return { type = 'executable', command = cmd, name = 'lldb' }
        end,
      },
      delve = {
        bin = 'dlv',
        make = function(cmd)
          return {
            type = 'server',
            port = '${port}',
            executable = {
              command = cmd,
              args = { 'dap', '-l', '127.0.0.1:${port}' },
            },
          }
        end,
      },
      python = {
        bin = 'python3',
        check = function(cmd)
          local probe = { cmd, '-c', 'import debugpy' }
          return vim.system(probe, { text = true }):wait().code == 0
        end,
        make = function(cmd)
          return {
            type = 'executable',
            command = cmd,
            args = { '-m', 'debugpy.adapter' },
          }
        end,
      },
      ['pwa-node'] = {
        bin = 'js-debug-adapter',
        make = function(cmd)
          return {
            type = 'server',
            host = '127.0.0.1',
            port = '${port}',
            executable = { command = cmd, args = { '${port}' } },
          }
        end,
      },
      kotlin = {
        bin = 'kotlin-debug-adapter',
        make = function(cmd)
          return { type = 'executable', command = cmd }
        end,
      },
      php = {
        bin = 'php-debug-adapter',
        make = function(cmd)
          return { type = 'executable', command = cmd }
        end,
      },
    }

    local available = {}
    for name, adapter in pairs(adapters) do
      local cmd = which(adapter.bin)
      if cmd and (not adapter.check or adapter.check(cmd)) then
        dap.adapters[name] = adapter.make(cmd)
        available[name] = true
      end
    end

    local languages = {
      {
        adapter = 'lldb',
        filetypes = { 'rust' },
        configs = {
          {
            name = 'Debug (cargo)',
            type = 'lldb',
            request = 'launch',
            program = cargo_executable,
            cwd = '${workspaceFolder}',
            args = {},
            stopOnEntry = false,
            initCommands = rust_formatters,
          },
        },
      },
      {
        adapter = 'lldb',
        filetypes = { 'c', 'cpp', 'zig', 'swift', 'asm' },
        configs = {
          {
            name = 'Debug (lldb)',
            type = 'lldb',
            request = 'launch',
            program = ask_executable,
            cwd = '${workspaceFolder}',
            args = {},
            stopOnEntry = false,
          },
        },
      },
      {
        adapter = 'delve',
        filetypes = { 'go' },
        configs = {
          {
            name = 'Debug package',
            type = 'delve',
            request = 'launch',
            program = '${fileDirname}',
            cwd = '${workspaceFolder}',
          },
          {
            name = 'Debug test',
            type = 'delve',
            request = 'launch',
            mode = 'test',
            program = '${fileDirname}',
            cwd = '${workspaceFolder}',
          },
        },
      },
      {
        adapter = 'python',
        filetypes = { 'python' },
        configs = {
          {
            name = 'Launch file',
            type = 'python',
            request = 'launch',
            program = '${file}',
            cwd = '${workspaceFolder}',
            console = 'integratedTerminal',
            justMyCode = false,
          },
        },
      },
      {
        adapter = 'pwa-node',
        filetypes = {
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
        },
        configs = {
          {
            name = 'Launch file',
            type = 'pwa-node',
            request = 'launch',
            program = '${file}',
            cwd = '${workspaceFolder}',
            sourceMaps = true,
          },
          {
            name = 'Attach to process',
            type = 'pwa-node',
            request = 'attach',
            processId = require('dap.utils').pick_process,
            cwd = '${workspaceFolder}',
            sourceMaps = true,
          },
        },
      },
      {
        adapter = 'kotlin',
        filetypes = { 'kotlin' },
        configs = {
          {
            name = 'Launch',
            type = 'kotlin',
            request = 'launch',
            projectRoot = '${workspaceFolder}',
            mainClass = function() return vim.fn.input 'Main class: ' end,
          },
        },
      },
      {
        adapter = 'php',
        filetypes = { 'php' },
        configs = {
          {
            name = 'Listen for Xdebug',
            type = 'php',
            request = 'launch',
            port = 9003,
          },
        },
      },
    }

    for _, language in ipairs(languages) do
      if available[language.adapter] then
        for _, filetype in ipairs(language.filetypes) do
          dap.configurations[filetype] = language.configs
        end
      end
    end


    require('nvim-dap-virtual-text').setup { commented = true }

    local dapui = require 'dapui'
    dapui.setup()
    dap.listeners.after.event_initialized.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })

    local icons = {
      Breakpoint = '●',
      BreakpointCondition = '⊜',
      BreakpointRejected = '⊘',
      LogPoint = '◆ ',
      Stopped = '⭔ ',
    }
    for type, icon in pairs(icons) do
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(
        'Dap' .. type,
        { text = icon, texthl = hl, numhl = hl }
      )
    end
  end,
}
