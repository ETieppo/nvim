local os_mod = require 'deps.sys'
local window = require 'buffer.window'
local OsNameEnum = require('deps.enums').OsNameEnum
local ShellNameEnum = require('deps.enums').ShellNameEnum

---@class ShellDefinitionProps
---@field command_args string[]
---@field command_group string
---@field command_separator string
---@field rc_file? string
---@field source_command? string

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
local RC_APPEND_TEMPLATE = [[printf '\n# %%s\n%%s\n' %s %s >> %s]]
local PATH_EXPORT_TEMPLATE = 'export PATH="$PATH:%s"'

---@type table<ShellNameEnum, ShellDefinitionProps>
local definitions = {
  [ShellNameEnum.zsh] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.zshrc',
    source_command = 'source',
  },
  [ShellNameEnum.bash] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.bashrc',
    source_command = 'source',
  },
  [ShellNameEnum.sh] = {
    command_args = POSIX_COMMAND_ARGS,
    command_group = POSIX_COMMAND_GROUP,
    command_separator = POSIX_COMMAND_SEPARATOR,
    rc_file = '~/.profile',
    source_command = '.',
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
    ---@param command string
    ---@return string
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
---@return string[]
function Shell.get_path_references(source)
  local relative = os_mod.get_home_relative_path(source)
  if not relative then return { source } end
  return {
    '$HOME/' .. relative,
    '${HOME}/' .. relative,
    '~/' .. relative,
    os_mod.expand_home_path(source),
  }
end

---@param references string[]
---@return boolean
function Shell:has_rc_entry(references)
  local file = io.open(os_mod.expand_home_path(self.rc_file), 'r')
  if not file then return false end

  local content = file:read '*a'
  file:close()

  return vim.iter(references):any(
    function(reference) return content:find(reference, 1, true) ~= nil end
  )
end

---@param label string
---@param line string
---@return string
function Shell:build_rc_append(label, line)
  return RC_APPEND_TEMPLATE:format(
    vim.fn.shellescape(label),
    vim.fn.shellescape(line),
    self.rc_file
  )
end

---@param label string
---@param source string
---@return string
function Shell:build_path_export(label, source)
  local relative = os_mod.get_home_relative_path(source)
  return self:build_rc_append(
    label,
    PATH_EXPORT_TEMPLATE:format(relative and '$HOME/' .. relative or source)
  )
end

---@return string
function Shell:build_rc_source()
  return self.source_command .. ' ' .. self.rc_file
end

---@param steps string[]
---@return string
function Shell:chain(steps) return table.concat(steps, POSIX_COMMAND_SEPARATOR) end

---@param commands string[]
---@param on_exit fun()
function Shell:run_in_terminal(commands, on_exit)
  window.close_dashboard()
  vim.cmd.tabnew()
  vim.fn.jobstart(self:build_argv(self:join(commands)), {
    term = true,
    on_exit = function() on_exit() end,
  })
  vim.cmd.startinsert()
end

return Shell
