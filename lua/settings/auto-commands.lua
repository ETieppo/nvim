vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup(
    'kickstart-highlight-yank',
    { clear = true }
  ),
  callback = function() vim.hl.hl_op() end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'image',
  callback = function(ev) vim.bo[ev.buf].bufhidden = 'wipe' end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  callback = function()
    local bt = vim.bo.buftype
    local ft = vim.bo.filetype
    local excluded_ft =
      { 'neo-tree', 'minimap', 'neominimap', 'aerial', 'dashboard' }
    local excluded_bt = { 'terminal', 'nofile', 'prompt', 'quickfix' }
    local is_excluded_ft = vim.tbl_contains(excluded_ft, ft)
    local is_excluded_bt = vim.tbl_contains(excluded_bt, bt)

    if is_excluded_ft or is_excluded_bt then
      vim.opt_local.statuscolumn = ''
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
    else
      vim.opt_local.statuscolumn = '%{v:lnum} %{v:relnum}%=%s'
      vim.opt_local.number = true
      vim.opt_local.relativenumber = true
    end

    if vim.api.nvim_buf_get_name(0) == '' then return end
    vim.schedule(function()
      for _, b in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_valid(b)
          and vim.bo[b].buflisted
          and vim.bo[b].buftype == ''
          and vim.api.nvim_buf_get_name(b) == ''
          and not vim.bo[b].modified
          and #vim.fn.win_findbuf(b) == 0
        then
          pcall(vim.api.nvim_buf_delete, b, { force = true })
        end
      end
    end)
  end,
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'FocusLost', 'BufLeave' }, {
  desc = 'Autosave',
  nested = true,
  callback = function(args)
    local buf = args.buf
    if
      vim.bo[buf].modified
      and vim.bo[buf].buftype == ''
      and vim.api.nvim_buf_get_name(buf) ~= ''
    then
      vim.api.nvim_buf_call(buf, function() vim.cmd 'silent! write' end)
    end
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'neo-tree', 'dbui', 'dbout' },
  callback = function()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].filetype == 'snacks_dashboard'
        then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end)
  end,
})
