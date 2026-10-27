local os_mod = require 'utils.os_mod'
local OsNameEnum = require 'utils.enums.os_name_enum'
local ShellNameEnum = require 'utils.enums.shell_name_enum'

---@class ShellDefinitionProps
---@field command_args string[]
---@field command_group string
---@field command_separator string
---@field rc_file? string
---@field source_command? string
---@field path_export_template? string

---@class ShellProps : ShellDefinitionProps
---@field name ShellNameEnum

---@class Shell : ShellProps
local Shell = {}
Shell.__index = Shell

local POSIX_COMMAND_ARGS = { '-c' }
local POSIX_COMMAND_GROUP = '{ %s; }'
local POSIX_COMMAND_SEPARATOR = ' && '
local POWERSHELL_COMMAND_ARGS = {
  '-NoLogo',
  '-NoProfile',
  '-ExecutionPolicy',
  'Bypass',
  '-Command',
}
local PRINTF_PATH_EXPORT_TEMPLATE =
  [[printf '\n# %s\nexport PATH="$PATH:%s"\n' >> %s]]

---@type table<ShellNameEnum, ShellDefinitionProps>
local definitions = {
  [ShellNameEnum.zsh] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.zshrc',
    source_command = 'source',
    path_export_template = [[echo '\n# %s\nexport PATH="$PATH:%s"' >> %s]],
  },
  [ShellNameEnum.bash] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.bashrc',
    source_command = 'source',
    path_export_template = PRINTF_PATH_EXPORT_TEMPLATE,
  },
  [ShellNameEnum.sh] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.profile',
    source_command = '.',
    path_export_template = PRINTF_PATH_EXPORT_TEMPLATE,
  },
  [ShellNameEnum.pwsh] = {
    command_args = POWERSHELL_COMMAND_ARGS,
    command_group = '%s',
    command_separator = ' ; ',
  },
  [ShellNameEnum.powershell] = {
    command_args = POWERSHELL_COMMAND_ARGS,
    command_group = '%s',
    command_separator = ' ; ',
  },
}

---@type table<string, boolean>
local unix_shell_names = {
  [ShellNameEnum.zsh] = true,
  [ShellNameEnum.bash] = true,
}

---@param name ShellNameEnum
---@return Shell
function Shell.create(name)
  return setmetatable(
    vim.tbl_extend('force', definitions[name], { name = name }),
    Shell
  )
end

---@param os_name OsNameEnum|nil
---@param shell_path string
---@param has_executable fun(name: string): boolean
---@return Shell
function Shell.detect(os_name, shell_path, has_executable)
  if os_name == OsNameEnum.windows then
    return Shell.create(
      has_executable(ShellNameEnum.pwsh) and ShellNameEnum.pwsh
        or ShellNameEnum.powershell
    )
  end

  local name = vim.fs.basename(shell_path)
  return Shell.create(unix_shell_names[name] and name or ShellNameEnum.sh)
end

---@param commands string[]
---@return string
function Shell:join(commands)
  local grouped = vim.tbl_map(
    function(command) return self.command_group:format(command) end,
    commands
  )
  return table.concat(grouped, self.command_separator)
end

---@param script string
---@return string[]
function Shell:build_argv(script)
  local argv = vim.list_extend({ self.name }, self.command_args)
  table.insert(argv, script)
  return argv
end

---@param source string
---@return boolean
function Shell:has_path_export(source)
  local file = io.open(os_mod.expand_home_path(self.rc_file), 'r')
  if not file then return false end

  local content = file:read '*a'
  file:close()

  local relative = os_mod.get_home_relative_path(source)
  local references = relative
      and {
        '$HOME/' .. relative,
        '${HOME}/' .. relative,
        '~/' .. relative,
        os_mod.expand_home_path(source),
      }
    or { source }

  return vim.iter(references):any(
    function(reference) return content:find(reference, 1, true) ~= nil end
  )
end

---@param command string|nil
---@param source string
---@param label string
---@param exports_path boolean
---@return string
function Shell:append_env_source(command, source, label, exports_path)
  local commands = { command }
  local relative = os_mod.get_home_relative_path(source)

  if exports_path then
    table.insert(
      commands,
      self.path_export_template:format(
        label,
        relative and '$HOME/' .. relative or source,
        self.rc_file
      )
    )
  end

  table.insert(commands, self.source_command .. ' ' .. self.rc_file)
  return table.concat(commands, POSIX_COMMAND_SEPARATOR)
end

local function close_dashboard_buffers()
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buffer)
      and vim.bo[buffer].filetype == 'snacks_dashboard'
    then
      pcall(vim.api.nvim_buf_delete, buffer, { force = true })
    end
  end
end

---@param commands string[]
---@param on_exit fun()
function Shell:run_in_terminal(commands, on_exit)
  close_dashboard_buffers()
  vim.cmd.tabnew()
  vim.fn.jobstart(self:build_argv(self:join(commands)), {
    term = true,
    on_exit = function() on_exit() end,
  })
  vim.cmd.startinsert()
end

return Shell
