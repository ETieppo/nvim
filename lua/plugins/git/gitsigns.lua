---@param action_name string
---@param ... any
---@return fun()
local function run_gitsigns_action(action_name, ...)
  local action_args = { ... }
  return function() require('gitsigns')[action_name](unpack(action_args)) end
end

---@param action_name string
---@return fun()
local function run_gitsigns_action_on_selection(action_name)
  return function()
    require('gitsigns')[action_name] { vim.fn.line '.', vim.fn.line 'v' }
  end
end

---@param direction 'next'|'prev'
---@param diff_key string
---@return fun()
local function navigate_to_hunk(direction, diff_key)
  return function()
    if vim.wo.diff then
      vim.cmd.normal { diff_key, bang = true }
      return
    end
    require('gitsigns').nav_hunk(direction)
  end
end

---@module 'lazy'
---@type LazySpec
return {
  'lewis6991/gitsigns.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    {
      ']c',
      navigate_to_hunk('next', ']c'),
      desc = 'Next git [C]hange',
    },
    {
      '[c',
      navigate_to_hunk('prev', '[c'),
      desc = 'Prev git [C]hange',
    },
    {
      '<leader>hs',
      run_gitsigns_action_on_selection 'stage_hunk',
      mode = 'v',
      desc = 'git [S]tage hunk',
    },
    {
      '<leader>hr',
      run_gitsigns_action_on_selection 'reset_hunk',
      mode = 'v',
      desc = 'git [R]eset hunk',
    },
    {
      '<leader>grh',
      run_gitsigns_action 'reset_hunk',
      desc = '[G]it [R]eset [H]unk',
    },
    {
      '<leader>gsb',
      run_gitsigns_action 'stage_buffer',
      desc = '[G]it [S]tage [B]uffer',
    },
    {
      '<leader>grb',
      run_gitsigns_action 'reset_buffer',
      desc = '[G]it [R]eset [B]uffer',
    },
    {
      '<leader>gph',
      run_gitsigns_action 'preview_hunk',
      desc = '[G]it [P]review [H]unk',
    },
    {
      '<leader>gdi',
      run_gitsigns_action 'diffthis',
      desc = '[G]it [D]iff [I]ndex',
    },
    {
      '<leader>gdl',
      run_gitsigns_action('diffthis', '@'),
      desc = '[G]it [D]iff [L]ast commit',
    },
    {
      '<leader>gbf',
      run_gitsigns_action 'blame_line',
      desc = '[G]it [B]lame [F]ull',
    },
    {
      '<leader>gbs',
      run_gitsigns_action 'toggle_current_line_blame',
      desc = '[G]it [B]lame [S]hort',
    },
    {
      '<leader>gpd',
      run_gitsigns_action 'preview_hunk_inline',
      desc = '[G]it [P]review [D]eleted',
    },
  },
  ---@module 'gitsigns'
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    signs = {
      add = { text = '+' }, ---@diagnostic disable-line: missing-fields
      change = { text = '~' }, ---@diagnostic disable-line: missing-fields
      delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
      topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
      changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
    },
  },
}
