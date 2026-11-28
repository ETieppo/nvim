local profile = require 'deps.profile'
local helpers = require 'utils.helpers'
local path = vim.fn.stdpath 'config' .. '/assets/'
---@type string[]
local dir_files = vim.fn.readdir(path)
local wall_selection = dir_files[vim.uv.hrtime() % #dir_files + 1]
local ART_CACHE_DIRECTORY = vim.fn.stdpath 'cache' .. '/dash_art'
local ART_HEIGHT_RATIO = 0.90
---@type integer?
local recording_job_id = nil
  local ASCII_ART = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠀⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⡀⠀⠘⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣤⣦⣤⣀⣀⣀⣤⣤⣀⠀⠀⠀⢀⣠⡆⠀⠀⠀⠀⠀⠀⠀⠀⠐⠚⠉⢉⣉⣛⣿⣿⣷⣶⣿⣿⣦⣀⢻⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣯⣍⣙⣿⣿⣿⣿⣟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠈⠛⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠦⢤⡀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⠟⠉⠀⠀⠉⠙⠻⣿⣿⣿⣿⠛⢿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⠟⠉⠉⠉⠛⢿⣿⣿⣿⣷⣦⣄⠀⠐⠉⠀⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣦⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⡛⠷⡀⠀⢰⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀⠿⣿⣿⣿⣿⣿⣿⣿⣦⣄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣦⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀⢤⠀⠀⠀⠈⠉⠙⠻⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⢿⠀⠀⠀⢿⡏⢿⣿⣿⣿⣿⣿⣷⣤⣄⡀⠀⠈⠳⣤⣄⣀⠀⠀⠀⠈⠿⠛⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⣿⣿⣿⠸⠀⠀⠀⠈⠳⠀⢙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣾⣿⣿⣿⠿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢤⡀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⡿⣿⠀⠀⠀⠀⠀⠐⠊⠉⣉⣩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣦⣽⣿⣶⣶⣦⣤⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢨⣿⢀⣤⣾⣋⣀⣀⠀⠀⠀⠀⣸⣿⣿⣿⣿⢀⠏⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣧⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠀⠀⠀⠀
⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣟⡲⠄⠀⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⡿⠋⠀⠈⢿⣿⣿⣿⣿⡆⠀⠈⠛⠋⠉⠀⠀⠀⠀⣈⠙⠁⠀⠀⠀⠀
⠀⠀⠀⣠⣾⣿⣿⣿⠿⠛⢿⣿⣿⣿⣿⣦⡀⢿⣿⣿⣿⣇⠀⠀⠀⠀⠀⠘⢁⣾⣿⣿⣿⡟⠀⠀⠀⠀⠈⣿⣿⣿⣿⣷⠀⠀⠀⠀⠤⢤⣀⠀⣼⡇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣿⣱⣿⣿⣧⠀⠀⠀⢹⣿⣿⣿⣧⠑⠸⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⠀⠀⣠⣴⣶⣾⣿⣿⣾⣿⣄⠀⠀⠀⠀⠀
⠀⢀⣴⣿⣿⠿⠛⠉⠀⠀⠀⣸⣿⣿⣿⣿⡇⠀⢻⣿⣿⣿⣿⣄⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⢸⣿⣿⣿⣿⡏⠀⢊⣵⣿⣿⣿⠿⠿⣿⣿⡿⢷⡄⠀⠀⠀
⠀⢺⣿⡿⠁⠀⠀⠀⠀⠀⣰⣿⣿⣿⡿⢹⠇⠀⠀⠻⣿⣿⣿⣿⣷⣄⠀⠀⠹⡇⠹⣿⣿⣿⣿⣿⣧⣠⣿⣿⣿⣿⣿⡇⢠⣿⣿⣿⣿⠃⠀⠀⢼⣿⣿⣮⣧⡀⠀⠀
⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⡇⠈⠀⠀⠀⠀⠘⢿⣿⣿⣿⣿⣿⣶⣤⣙⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠁⣿⣿⣿⣿⡆⠀⠀⠀⠉⠙⠻⣿⣿⡆⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣶⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⢿⠻⣿⣿⣿⣆⠀⠀⠀⠀⠀⠈⠛⠁⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⣿⣿⣿⣿⣷⣤⣀⠀⠀⠀⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠀⠈⠃⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣶⣤⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⣠⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣤⣤⣶⣶⣿⣿⣿⣿⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⡀⠀⠀⢴⣮⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⡁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⡀⠀⠀⠔⢻⣿⣿⣿⣶⣤⣤⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣡⣴⣶⣤⣀⡀⠀⢰⣞⡛⢲⣄
⣾⣥⣤⣼⣿⣷⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣾⣶⣾⡿
]]

---@param image_path string
---@param cache_file string
---@param width integer
---@param height integer
local function record_art(image_path, cache_file, width, height)
  if recording_job_id then vim.fn.jobstop(recording_job_id) end
  ---@type string[]
  local chunks = {}
  recording_job_id = vim.fn.jobstart({ 'pixterm', '-d', '2', '-s', '1', image_path }, {
    pty = true,
    width = width,
    height = height,
    on_stdout = function(_, data)
      chunks[#chunks + 1] = table.concat(data, '\n')
    end,
    on_exit = function(job_id, code)
      if recording_job_id == job_id then recording_job_id = nil end
      if code ~= 0 then return end
      vim.fn.mkdir(ART_CACHE_DIRECTORY, 'p')
      local temporary_file = cache_file .. '.tmp'
      local file = assert(vim.uv.fs_open(temporary_file, 'w', 420))
      vim.uv.fs_write(file, table.concat(chunks))
      vim.uv.fs_close(file)
      vim.uv.fs_rename(temporary_file, cache_file)
    end,
  })
end

---@param width integer
---@param height integer
local function build_image_section(width, height)
  local image_path = path .. wall_selection
  local cache_file = ('%s/%s.%dx%d.ans'):format(
    ART_CACHE_DIRECTORY,
    wall_selection,
    width,
    height
  )
  local command = 'bash -c "pixterm -d 2 -s 1 ' .. image_path .. '; cat"'
  if vim.uv.fs_stat(cache_file) then
    command = 'cat ' .. vim.fn.shellescape(cache_file) .. '; cat'
  else
    helpers.on_very_lazy(
      function() record_art(image_path, cache_file, width, height) end
    )
  end
  return {
    section = 'terminal',
    cmd = command,
    ttl = 0,
    width = width,
    height = height,
    padding = 0,
    indent = 0,
  }
end

---@param width integer
---@param height integer
local function build_ascii_section(width, height)
  local lines = vim.split(ASCII_ART, '\n')
  local art_w = 0
  for _, l in ipairs(lines) do
    art_w = math.max(art_w, vim.fn.strdisplaywidth(l))
  end

  local left = string.rep(' ', math.max(0, math.floor((width - art_w) / 2)))
  local top = math.max(0, math.floor((height - #lines) / 2))
  local out = {}

  for _ = 1, top do
    table.insert(out, '')
  end
  for _, l in ipairs(lines) do
    table.insert(out, left .. l)
  end

  return {
    section = 'terminal',
    width = width,
    height = height,
    cmd = "cat << 'EOF'\n"
      .. table.concat(out, '\n')
      .. '\nEOF\ntail -f /dev/null',
  }
end

return function()
  local width = vim.o.columns
  local height = math.floor(vim.o.lines * ART_HEIGHT_RATIO)
  if profile.is_max_profile() then return build_image_section(width, height) end
  return build_ascii_section(width, height)
end
