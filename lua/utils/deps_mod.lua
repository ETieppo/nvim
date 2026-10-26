local os_mod = require 'utils.os_mod'
local OsNameEnum = require 'utils.enums.os_name_enum'
local PackageManagerNameEnum = require 'utils.enums.package_manager_name_enum'
local InstallStrategyEnum = require 'utils.enums.install_strategy_enum'
local InstallPlanDto = require 'utils.dtos.install_plan_dto'

---@alias InstallInstructionProps string

---@alias OsInstructionKeyProps 'unix'|'macos'|'archlinux'|'windows'

---@class OsInstructionProps
---@field unix? InstallInstructionProps
---@field macos? InstallInstructionProps
---@field archlinux? InstallInstructionProps
---@field windows? InstallInstructionProps

---@class DepProps
---@field cmd string
---@field alternative_cmds? string[]
---@field install_command? InstallInstructionProps
---@field os? OsInstructionProps
---@field depends_on? string
---@field min_version? string
---@field version_cmd? string

---@class DependencyProbeProps
---@field has_executable fun(name: string): boolean
---@field read_command_output fun(command: string): string|nil

---@class InstallEnvironmentProps : DependencyProbeProps
---@field os_name OsNameEnum|nil
---@field package_manager PackageManager|nil

local M = {}

local SHELL_CHARACTERS_PATTERN = '[%s|&;$()<>`\'"]'

---@return InstallEnvironmentProps
function M.get_live_environment()
  return {
    os_name = os_mod.get_name(),
    package_manager = os_mod.get_package_manager(),
    has_executable = os_mod.has_executable,
    read_command_output = os_mod.read_command_output,
  }
end

---@param output string
---@return vim.Version|nil
function M.parse_version(output)
  local raw = output:match '%d+%.%d+%.%d+' or output:match '%d+%.%d+'
  if not raw then return nil end

  local ok, version = pcall(vim.version.parse, raw, { strict = false })
  return ok and version or nil
end

---@param dep DepProps
---@param probe DependencyProbeProps
---@return boolean
function M.has_any_executable(dep, probe)
  if probe.has_executable(dep.cmd) then return true end
  for _, alternative in ipairs(dep.alternative_cmds or {}) do
    if probe.has_executable(alternative) then return true end
  end
  return false
end

---@param dep DepProps
---@param probe DependencyProbeProps
---@return boolean
function M.is_installed(dep, probe)
  if not M.has_any_executable(dep, probe) then return false end
  if not dep.min_version then return true end

  local output =
    probe.read_command_output(dep.version_cmd or (dep.cmd .. ' --version'))
  local version = output and M.parse_version(output)
  if not version then return false end

  return not vim.version.lt(version, dep.min_version)
end

---@param deps DepProps[]
---@param probe? DependencyProbeProps
---@return DepProps[]
function M.find_missing(deps, probe)
  local active_probe = probe or M.get_live_environment()
  return vim.tbl_filter(
    function(dep) return not M.is_installed(dep, active_probe) end,
    deps
  )
end

---@param environment InstallEnvironmentProps
---@return OsInstructionKeyProps[]
local function get_os_instruction_keys(environment)
  if environment.os_name == OsNameEnum.windows then return { 'windows' } end
  if environment.os_name == OsNameEnum.macos then return { 'macos', 'unix' } end

  local package_manager = environment.package_manager
  if
    package_manager and package_manager.name == PackageManagerNameEnum.pacman
  then
    return { 'archlinux', 'unix' }
  end
  return { 'unix' }
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return InstallInstructionProps
function M.select_instruction(dep, environment)
  local by_os = dep.os or {}

  for _, key in ipairs(get_os_instruction_keys(environment)) do
    local instruction = by_os[key]
    if instruction ~= nil then return instruction end
  end

  if dep.install_command ~= nil then return dep.install_command end
  return dep.cmd
end

---@param instruction InstallInstructionProps
---@return InstallStrategyEnum
function M.classify(instruction)
  if instruction:find(SHELL_CHARACTERS_PATTERN) then
    return InstallStrategyEnum.shell
  end
  return InstallStrategyEnum.package
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return string|nil command
---@return InstallStrategyEnum|nil strategy
function M.build_install_command(dep, environment)
  local instruction = M.select_instruction(dep, environment)
  local strategy = M.classify(instruction)
  if strategy == InstallStrategyEnum.shell then return instruction, strategy end

  if not environment.package_manager then return nil, nil end
  return environment.package_manager:build_install_command { instruction },
    strategy
end

---@param deps DepProps[]
---@param environment InstallEnvironmentProps
---@return InstallPlanDto
function M.plan(deps, environment)
  local plan = InstallPlanDto.new()

  for _, dep in ipairs(deps) do
    if M.is_installed(dep, environment) then
      table.insert(plan.installed, dep.cmd)
    else
      local command, strategy = M.build_install_command(dep, environment)
      if command then
        table.insert(plan.commands, command)
        if strategy == InstallStrategyEnum.package then
          plan.uses_package_manager = true
        end
      else
        table.insert(plan.skipped, dep.cmd)
      end
    end
  end

  if plan.uses_package_manager and environment.package_manager then
    plan.commands = vim.list_extend(
      environment.package_manager:get_bootstrap_commands(),
      plan.commands
    )
  end

  return plan
end

---@param plan InstallPlanDto
local function notify_plan(plan)
  if #plan.installed > 0 then
    vim.notify('Already installed: ' .. table.concat(plan.installed, ', '))
  end

  if #plan.skipped > 0 then
    vim.notify(
      'No install command (manual intervention needed): '
        .. table.concat(plan.skipped, ', '),
      vim.log.levels.WARN
    )
  end
end

---@param deps DepProps[]
function M.install(deps)
  local plan = M.plan(deps, M.get_live_environment())

  if #plan.commands == 0 and #plan.skipped == 0 then
    vim.notify('All dependencies installed.', vim.log.levels.INFO)
    return
  end

  notify_plan(plan)
  if #plan.commands > 0 then os_mod.run_in_terminal(plan.commands) end
end

return M
