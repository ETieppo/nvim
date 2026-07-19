return {
  'sschleemilch/slimline.nvim',
  event = 'VeryLazy',
  config = function()
    local frames = {
      'ᗧ• • •🍒      ',
      'ᗧ• • •🍒      ',
      'ᗧ• • •🍒      ',

      '  ᗧ • 🍒       ',
      '  ᗧ • 🍒       ',
      '  ᗧ • 🍒       ',

      '    ᗧ 🍒      ᗣ',
      '    ᗧ 🍒      ᗣ',
      '    ᗧ 🍒      ᗣ',
      '    ᗧ 🍒      ᗣ',
      '    ᗧ 🍒      ᗣ',

      '    ᗧ 🍒     ᗣ ',
      '    ᗧ 🍒     ᗣ ',
      '    ᗧ 🍒     ᗣ ',
      '    ᗧ 🍒     ᗣ ',
      '    ᗧ 🍒     ᗣ ',

      '   ᗤ  🍒    ᗣ  ',
      '   ᗤ  🍒    ᗣ  ',
      '   ᗤ  🍒    ᗣ  ',

      '  ᗤ   🍒    ᗣ  ',
      '  ᗤ   🍒    ᗣ  ',
      '  ᗤ   🍒    ᗣ  ',

      ' ᗤ    🍒    ᗣ  ',
      ' ᗤ    🍒    ᗣ  ',
      ' ᗤ    🍒    ᗣ  ',
      'ᗤ     🍒    ᗣ  ',
      'ᗤ     🍒    ᗣ  ',
      'ᗤ     🍒    ᗣ  ',
    }
    local spinner = { tokens = {}, frame = 1, timer = nil }

    local function stop_timer()
      if spinner.timer then
        spinner.timer:stop()
        spinner.timer:close()
        spinner.timer = nil
        vim.cmd 'redrawstatus'
      end
    end

    vim.api.nvim_create_autocmd('LspProgress', {
      group = vim.api.nvim_create_augroup(
        'slimline-lsp-progress',
        { clear = true }
      ),
      callback = function(ev)
        local value = ev.data and ev.data.params and ev.data.params.value
        local token = ev.data and ev.data.params and ev.data.params.token
        if not value or not token then return end

        if value.kind == 'begin' then
          spinner.tokens[token] = true
        elseif value.kind == 'end' then
          spinner.tokens[token] = nil
        end

        local active = next(spinner.tokens) ~= nil
        if active and not spinner.timer then
          spinner.timer = vim.uv.new_timer()
          spinner.timer:start(
            0,
            120,
            vim.schedule_wrap(function()
              -- válvula de escape: se o cliente LSP sumiu, para tudo
              if not next(spinner.tokens) or #vim.lsp.get_clients() == 0 then
                spinner.tokens = {}
                stop_timer()
                return
              end
              spinner.frame = (spinner.frame % #frames) + 1
              vim.cmd 'redrawstatus'
            end)
          )
        elseif not active then
          stop_timer()
        end
      end,
    })

    require('slimline').setup {
      components = {
        center = {
          function()
            if next(spinner.tokens) then return frames[spinner.frame] end
            return ''
          end,
        },
      },
    }
  end,
}
