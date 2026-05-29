return {
  'okuuva/auto-save.nvim',
  version = '^1.0.0',
  cmd = 'ASToggle',
  event = { 'InsertLeave' },
  opts = {
    trigger_events = {
      immediate_save = {},
      defer_save = { 'InsertLeave', 'TextChanged' },
      cancel_deferred_save = { 'InsertEnter' },
    },
  },
}
