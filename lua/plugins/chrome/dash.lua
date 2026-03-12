return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-mini/mini.icons' },
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    local image_win = nil
    local image_buf = nil

    local function close_alpha_image()
      if image_win and vim.api.nvim_win_is_valid(image_win) then pcall(vim.api.nvim_win_close, image_win, true) end
      image_win = nil
      image_buf = nil
    end

    local function alpha_pixterm()
      close_alpha_image()
      local image_path = vim.fs.abspath '~/.config/nvim/assets/pacman.jpg'
      local width = vim.o.columns
      local height = math.floor(vim.o.lines * 0.75)
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = 'wipe'

      local win = vim.api.nvim_open_win(buf, false, {
        relative = 'editor',
        width = width,
        height = height,
        row = 0,
        col = 0,
        style = 'minimal',
        border = 'none',
        zindex = 10,
      })

      image_buf = buf
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
          on_exit = function()
            if image_win and vim.api.nvim_win_is_valid(image_win) then vim.api.nvim_win_set_option(image_win, 'winblend', 0) end
          end,
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

    local function make_projects_section()
      local projects = get_recent_projects(5)
      local lines = { '󰉋  Projetos recentes', '' }

      if #projects == 0 then
        table.insert(lines, 'Nenhum projeto recente encontrado')
      else
        for i, path in ipairs(projects) do
          local name = vim.fn.fnamemodify(path, ':t')
          local pretty = vim.fn.fnamemodify(path, ':~')
          table.insert(lines, string.format('%d. %s', i, name))
          table.insert(lines, '   ' .. pretty)
          if i < #projects then table.insert(lines, '') end
        end
      end

      return {
        type = 'text',
        val = lines,
        opts = {
          position = 'center',
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
    local projects_section = make_projects_section()

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
