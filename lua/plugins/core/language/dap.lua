return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'jay-babu/mason-nvim-dap.nvim',
    'theHamsta/nvim-dap-virtual-text',
  },
  keys = {
    { '<leader>da', function() require('dap').continue() end, desc = '[D]ebugger [A]ttach' },
    {
      '<leader>dk',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
      desc = '[D]ebugger [K]ill',
    },
    { '<leader>dsi', function() require('dap').step_into() end, desc = '[D]ebug [S]tep [I]nto' },
    { '<leader>dsj', function() require('dap').step_over() end, desc = '[D]ebug [S]tep over' },
    { '<leader>dso', function() require('dap').step_out() end, desc = '[D]ebug [S]tep [O]ut' },
    { '<leader>bt', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
    { '<leader>bT', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = 'Conditional Breakpoint' },
    { '<leader>dsr', function() require('dapui').toggle() end, desc = 'Toggle DAP UI' },
  },
  config = function()
    local dap = require 'dap'

    require('mason-nvim-dap').setup {
      ensure_installed = { 'codelldb', 'js-debug-adapter' },
      automatic_installation = true,
    }

    local function native_program()
      if vim.fn.filereadable(vim.fn.getcwd() .. '/Cargo.toml') == 1 then
        vim.fn.system 'cargo build'
        local meta = vim.fn.json_decode(vim.fn.system 'cargo metadata --no-deps --format-version 1')
        local name = meta.packages[1].targets[1].name
        local path = vim.fn.getcwd() .. '/target/debug/' .. name
        if vim.fn.filereadable(path) == 1 then return path end
      end
      return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file')
    end

    local function ask_executable() return vim.fn.input('Executable: ', vim.fn.getcwd() .. '/', 'file') end

    local codelldb = vim.fn.stdpath 'data' .. '/mason/packages/codelldb/extension/adapter/codelldb'
    dap.adapters.codelldb = {
      type = 'server',
      port = '${port}',
      executable = {
        command = codelldb,
        args = { '--port', '${port}' },
      },
    }

    dap.configurations.rust = {
      {
        name = 'Debug (codelldb)',
        type = 'codelldb',
        request = 'launch',
        program = native_program,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    dap.configurations.c = {
      {
        name = 'Debug (codelldb)',
        type = 'codelldb',
        request = 'launch',
        program = ask_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    dap.configurations.zig = {
      {
        name = 'Debug (codelldb)',
        type = 'codelldb',
        request = 'launch',
        program = ask_executable,
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
      },
    }

    local js_debug = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = {
        command = 'node',
        args = { js_debug, '${port}' },
      },
    }

    for _, lang in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[lang] = {
        {
          type = 'pwa-node',
          request = 'launch',
          name = 'Launch file',
          program = '${file}',
          cwd = '${workspaceFolder}',
          sourceMaps = true,
        },
      }
    end

    require('nvim-dap-virtual-text').setup { commented = true }

    local dapui = require 'dapui'
    dapui.setup()
    dap.listeners.before.attach.dapui_config = function() dapui.open() end
    dap.listeners.before.launch.dapui_config = function() dapui.open() end
    dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
    dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local icons = vim.g.have_nerd_font and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆ ', Stopped = '⭔ ' }
    for type, icon in pairs(icons) do
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define('Dap' .. type, { text = icon, texthl = hl, numhl = hl })
    end
  end,
}
