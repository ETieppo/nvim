return {
  'gen740/SmoothCursor.nvim',
  event = 'VeryLazy',
  config = function()
    vim.api.nvim_set_hl(0, 'SmoothCursorYellow1', { fg = '#FFD400' })
    vim.api.nvim_set_hl(0, 'SmoothCursorYellow2', { fg = '#FFC000' })
    vim.api.nvim_set_hl(0, 'SmoothCursorScarlet1', { fg = '#FF2400' })
    vim.api.nvim_set_hl(0, 'SmoothCursorScarlet2', { fg = '#E62000' })
    vim.api.nvim_set_hl(0, 'SmoothCursorRed1', { fg = '#CC1D00' })
    vim.api.nvim_set_hl(0, 'SmoothCursorRed2', { fg = '#991600' })
    vim.api.nvim_set_hl(0, 'SmoothCursorBlue1', { fg = '#0B1F5C' })
    vim.api.nvim_set_hl(0, 'SmoothCursorBlue2', { fg = '#102766' })
    vim.api.nvim_set_hl(0, 'SmoothCursorBlue3', { fg = '#183A8F' })

    local cyr = {
      'б',
      'г',
      'д',
      'ж',
      'з',
      'и',
      'й',
      'л',
      'п',
      'ф',
      'ц',
      'ч',
      'ш',
      'щ',
      'ы',
      'э',
      'ю',
      'я',
    }

    require('smoothcursor').setup {
      type = 'matrix',
      autostart = true,
      always_redraw = true,
      speed = 15,
      intervals = 25,
      priority = 10,
      timeout = 3000,
      threshold = 0,
      max_threshold = nil,
      disable_float_win = false,
      enabled_filetypes = nil,
      disabled_filetypes = nil,
      show_last_positions = nil,

      matrix = {
        head = {
          cursor = cyr,
          texthl = { 'SmoothCursorYellow1' },
          linehl = nil,
        },

        body = {
          length = 9,
          cursor = cyr,

          -- aqui sai o aleatório e entra o degradê fixo
          texthl = function(_, linenr)
            local cur = vim.fn.line '.'
            local d = math.abs(cur - linenr)

            if d <= 1 then
              return 'SmoothCursorYellow2'
            elseif d == 2 then
              return 'SmoothCursorScarlet1'
            elseif d == 3 then
              return 'SmoothCursorScarlet2'
            elseif d == 4 then
              return 'SmoothCursorRed1'
            elseif d == 5 then
              return 'SmoothCursorRed2'
            elseif d == 6 then
              return 'SmoothCursorBlue1'
            elseif d == 7 then
              return 'SmoothCursorBlue2'
            else
              return 'SmoothCursorBlue3'
            end
          end,
        },

        tail = {
          cursor = cyr,
          texthl = { 'SmoothCursorBlue3' },
        },

        unstop = false,
      },
    }
  end,
}
