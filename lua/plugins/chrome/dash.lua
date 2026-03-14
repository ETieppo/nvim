return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-mini/mini.icons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    local image_win = nil

    local function close_alpha_image()
      if image_win and vim.api.nvim_win_is_valid(image_win) then pcall(vim.api.nvim_win_close, image_win, true) end
      image_win = nil
    end

    local function alpha_pixterm()
      close_alpha_image()
      local image_path = vim.fs.abspath '~/.config/nvim/assets/pacman.jpg'
      local width = vim.o.columns
      local height = math.floor(vim.o.lines * 0.75)
      local buf = vim.api.nvim_create_buf(false, true)

      vim.bo[buf].bufhidden = 'wipe'
      vim.api.nvim_set_hl(0, 'AlphaImageBg', {
        bg = '#000000',
      })

      local win = vim.api.nvim_open_win(buf, false, {
        relative = 'editor',
        width = width,
        height = height,
        row = 0,
        col = 0,
        style = 'minimal',
        border = 'none',
        zindex = 10,
        focusable = false,
        mouse = false,
      })

      vim.api.nvim_set_option_value('winhighlight', 'Normal:AlphaImageBg,NormalFloat:AlphaImageBg,EndOfBuffer:AlphaImageBg', { win = win })
      image_win = win

      vim.api.nvim_buf_call(buf, function()
        vim.fn.jobstart({
          'pixterm',
          '-d',
          '2',
          '-s',
          '1',
          image_path,
        }, {
          term = true,
          on_exit = function() vim.api.nvim_set_option_value('winblend', 0, { win = image_win }) end,
        })
      end)
    end

    local function get_project_root(path)
      local file = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
      if vim.fn.filereadable(file) ~= 1 then return nil end

      local dir = vim.fn.fnamemodify(file, ':h')
      local git_dir = vim.fs.find('.git', {
        path = dir,
        upward = true,
        type = 'directory',
        stop = vim.loop.os_homedir(),
      })[1]

      if git_dir then return vim.fs.dirname(git_dir) end
      return nil
    end

    local function get_cwd_entries(limit)
      local cwd = vim.fn.getcwd()
      local entries = {}

      for name, typ in vim.fs.dir(cwd) do
        table.insert(entries, {
          name = name,
          type = typ,
        })
      end

      table.sort(entries, function(a, b)
        if a.type ~= b.type then return a.type == 'directory' end
        return a.name:lower() < b.name:lower()
      end)

      if limit and #entries > limit then
        while #entries > limit do
          table.remove(entries)
        end
      end

      return cwd, entries
    end

    local function get_recent_projects(limit)
      local seen = {}
      local projects = {}

      for _, file in ipairs(vim.v.oldfiles) do
        local root = get_project_root(file)
        if root and not seen[root] then
          seen[root] = true
          table.insert(projects, root)
          if #projects >= limit then break end
        end
      end

      return projects
    end

    local function get_recent_project_lines(limit)
      local projects = get_recent_projects(limit)
      local lines = { '', '󰉋  RECENT', '' }

      if #projects == 0 then
        table.insert(lines, '--')
      else
        for i, path in ipairs(projects) do
          local name = vim.fn.fnamemodify(path, ':t')
          local pretty = vim.fn.fnamemodify(path, ':~')
          table.insert(lines, string.format('%d. %s', i, (name .. ' - ' .. pretty)))
        end
      end

      return lines
    end

    local function pad_right(str, width)
      str = str or ''
      local display_width = vim.fn.strdisplaywidth(str)
      if display_width >= width then return str end
      return str .. string.rep(' ', width - display_width)
    end

    local function chunk_list(list, chunk_size)
      local chunks = {}
      for i = 1, #list, chunk_size do
        table.insert(chunks, vim.list_slice(list, i, math.min(i + chunk_size - 1, #list)))
      end
      return chunks
    end

    local function make_two_column_section()
      local left = get_recent_project_lines(5)
      local cwd, entries = get_cwd_entries(30)
      local right_items = {
        '',
        string.upper(vim.fn.fnamemodify(cwd, ':t')),
        '',
      }

      if #entries == 0 then
        table.insert(right_items, '--')
      else
        for _, item in ipairs(entries) do
          local icon = item.type == 'directory' and '' or '󰈔'
          table.insert(right_items, string.format('%s %s', icon, item.name))
        end
      end

      local header_lines = 3
      local body = {}
      for i = header_lines + 1, #right_items do
        table.insert(body, right_items[i])
      end
      local right_chunks = chunk_list(body, 5)
      local right_lines = {}

      for row = 1, math.max(5, #body) do
        local line = ''

        for col, chunk in ipairs(right_chunks) do
          local text = chunk[row] or ''
          line = line .. pad_right(text, 18)
          if col < #right_chunks then line = line .. '   ' end
        end

        table.insert(right_lines, line)
      end

      right_lines = {
        right_items[1],
        right_items[2],
        right_items[3],
        unpack(right_lines),
      }

      local lines = {}
      local left_width = math.floor(vim.o.columns * 0.28)
      local total = math.max(#left, #right_lines)

      for i = 1, total do
        local l = left[i] or ''
        local r = right_lines[i] or ''
        table.insert(lines, pad_right(l, left_width) .. '   ' .. r)
      end

      return {
        type = 'text',
        val = lines,
        opts = {
          position = 'left',
          hl = 'AlphaButtons',
        },
      }
    end

    vim.api.nvim_create_autocmd('TermOpen', {
      callback = function(args)
        local b = args.buf
        vim.opt_local.list = false
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = 'no'
        vim.opt_local.cursorline = false
        vim.opt_local.statuscolumn = ''
        vim.opt_local.winbar = ''
        vim.opt_local.wrap = false
        vim.opt_local.spell = false
        vim.bo[b].filetype = 'alpha_pixterm'
        vim.bo[b].bufhidden = 'wipe'
      end,
    })

    vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
      callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft ~= 'alpha' and ft ~= 'alpha_pixterm' then close_alpha_image() end
      end,
    })

    vim.api.nvim_create_autocmd('VimResized', {
      callback = function()
        if vim.bo.filetype == 'alpha' then
          vim.schedule(function()
            alpha_pixterm()
            pcall(vim.cmd, 'AlphaRedraw')
          end)
        else
          close_alpha_image()
        end
      end,
    })

    dashboard.section.header.val = {}
    local projects_section = make_two_column_section()

    dashboard.config.layout = {
      { type = 'padding', val = 38 },
      projects_section,
      { type = 'padding', val = 0 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
    if vim.fn.argc() == 0 then vim.schedule(alpha_pixterm) end
  end,
}
