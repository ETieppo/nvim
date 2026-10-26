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
    require('utils.dap_mod').setup()

    require('nvim-dap-virtual-text').setup { commented = true }

    local dapui = require 'dapui'
    dapui.setup()
    dap.listeners.after.event_initialized.dapui_config = function() dapui.open() end
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
