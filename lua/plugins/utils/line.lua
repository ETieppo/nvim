return {
  'sschleemilch/slimline.nvim',
  event = 'VeryLazy',
  config = function()
    local frames = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
    local spinner = { count = 0, frame = 1, timer = nil }

    vim.api.nvim_create_autocmd('LspProgress', {
      group = vim.api.nvim_create_augroup('slimline-lsp-progress', { clear = true }),
      callback = function(ev)
        local kind = ev.data and ev.data.params and ev.data.params.value and ev.data.params.value.kind
        if kind == 'begin' then
          spinner.count = spinner.count + 1
          if not spinner.timer then
            spinner.timer = vim.uv.new_timer()
            spinner.timer:start(0, 80, vim.schedule_wrap(function()
              spinner.frame = (spinner.frame % #frames) + 1
              vim.cmd('redrawstatus!')
            end))
          end
        elseif kind == 'end' then
          spinner.count = math.max(0, spinner.count - 1)
          if spinner.count == 0 and spinner.timer then
            spinner.timer:stop()
            spinner.timer:close()
            spinner.timer = nil
            vim.cmd('redrawstatus!')
          end
        end
      end,
    })

    require('slimline').setup({
      spaces = {
        components = '',
        left = '',
        right = '',
      },
      sep = {
        hide = {
          first = true,
          last = true,
        },
        left = '',
        right = '',
      },
      components = {
        center = {
          function()
            if spinner.count > 0 then
              return frames[spinner.frame]
            end
            return ''
          end,
        },
      },
    })
  end,
}
