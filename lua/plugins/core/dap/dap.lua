---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    { '<leader>da', function() require('dap').continue() end, desc = '[D]ebugger [A]ttach' },
    { '<leader>dsi', function() require('dap').step_into() end, desc = '[D]ebug: [S]tep [I]nto' },
    { '<leader>dsj', function() require('dap').step_over() end, desc = '[D]ebug: [S]tep [J]ump' },
    { '<leader>dso', function() require('dap').step_out() end, desc = '[D]ebug: [S]tep [O]ut' },
    { '<leader>bt', function() require('dap').toggle_breakpoint() end, desc = 'Debugger: Toggle Breakpoint' },
    { '<leader>bT', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, desc = '[D]ebugger: [T]oggle condition [B]reakpoint' },
    { '<leader>dsr', function() require('dapui').toggle() end, desc = '[D]ebugger: See last session result.' },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆ ', Stopped = '⭔ ' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    -- Abre/fecha o UI do DAP automaticamente ao debugar
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close
  end,
}
