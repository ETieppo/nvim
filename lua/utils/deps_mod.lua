local os_mod = require 'utils.os_mod'
local Shell = require 'utils.shell'
local PackageManager = require 'utils.package_manager'
local OsNameEnum = require 'utils.enums.os_name_enum'
local InstallPlanDto = require 'utils.dtos.install_plan_dto'

---@alias OsInstructionKeyProps 'unix'|'macos'|'linux'|'windows'

---@class OsInstructionProps
---@field unix? string
---@field macos? string
---@field linux? string
---@field windows? string

---@class ReleaseWrapperProps
---@field runtime string
---@field entry string

---@class ReleaseProps
---@field repo string
---@field asset_pattern string
---@field bin_subdir? string
---@field wrapper? ReleaseWrapperProps

---@class DepProps
---@field cmd string
---@field lang? string
---@field alternative_cmds? string[]
---@field check_cmd? string
---@field install_command? string
---@field os? OsInstructionProps
---@field depends_on? string
---@field min_version? string
---@field push_env_source? string
---@field release? ReleaseProps
---@field supported_os? OsNameEnum[]

---@class InstallEnvironmentProps
---@field os_name OsNameEnum|nil
---@field package_manager PackageManager|nil
---@field shell Shell
---@field has_executable fun(name: string): boolean
---@field read_command_output fun(command: string): string|nil
---@field confirm_install InstallConfirmationProps

local M = {}
---@type table<OsNameEnum, OsInstructionKeyProps[]>
local OS_INSTRUCTION_KEYS = {
  [OsNameEnum.macos] = { 'macos', 'unix' },
  [OsNameEnum.linux] = { 'linux', 'unix' },
  [OsNameEnum.windows] = { 'windows' },
}
local SHELL_CHARACTERS_PATTERN = '[%s|&;$()<>`\'"]'
local VERSION_FLAGS = { '--version', 'version', '-version' }
local RELEASES_DIR_NAME = 'debug-adapters'
local RELEASE_DOWNLOAD_STEPS = {
  'test -n "$url"',
  'rm -rf "$dir"',
  'mkdir -p "$dir"',
  'curl -fsSL -o "$dir/asset" "$url"',
  'case "$url" in *.tar.gz|*.tgz) tar -xzf "$dir/asset" -C "$dir" ;; *) unzip -q "$dir/asset" -d "$dir" ;; esac',
  'rm "$dir/asset"',
}

---@param package_manager_name PackageManagerNameEnum
---@param package_name string
---@return boolean
local function confirm_install(package_manager_name, package_name)
  return vim.fn.confirm(
    ('Install prebuilt binary %s with %s?'):format(
      package_name,
      package_manager_name
    ),
    '&Yes\n&No',
    2
  ) == 1
end

---@return InstallEnvironmentProps
local function get_live_environment()
  local os_name = os_mod.get_name()
  return {
    os_name = os_name,
    package_manager = PackageManager.detect(os_name, os_mod.has_executable),
    shell = Shell.detect(os_name, vim.o.shell, os_mod.has_executable),
    has_executable = os_mod.has_executable,
    read_command_output = os_mod.read_command_output,
    confirm_install = confirm_install,
  }
end

---@param deps DepProps[]
---@param os_name OsNameEnum|nil
---@return DepProps[]
local function filter_supported(deps, os_name)
  return vim.tbl_filter(
    function(dep)
      return not dep.supported_os
        or vim.list_contains(dep.supported_os, os_name)
    end,
    deps
  )
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return boolean
local function is_present(dep, environment)
  if dep.check_cmd then
    return environment.read_command_output(dep.check_cmd) ~= nil
  end

  return environment.has_executable(dep.cmd)
    or vim.iter(dep.alternative_cmds or {}):any(environment.has_executable)
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return vim.Version|nil
local function find_version(dep, environment)
  for _, flag in ipairs(VERSION_FLAGS) do
    local output = environment.read_command_output(dep.cmd .. ' ' .. flag)
    local version = output and vim.version.parse(output, { strict = false })
    if version then return version end
  end
  return nil
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return boolean
local function is_installed(dep, environment)
  if not is_present(dep, environment) then return false end
  if not dep.min_version then return true end

  local version = find_version(dep, environment)
  return version ~= nil and not vim.version.lt(version, dep.min_version)
end

---@param source string|nil
---@param shell Shell
---@return boolean
local function lacks_path_export(source, shell)
  return source ~= nil
    and shell.rc_file ~= nil
    and not shell:has_path_export(source)
end

---@param cmd string
---@return string
local function get_release_dir(cmd)
  return vim.fs.joinpath(vim.fn.stdpath 'data', RELEASES_DIR_NAME, cmd)
end

---@param cmd string
---@param release ReleaseProps
---@return string
local function build_release_command(cmd, release)
  local steps = {
    ("dir='%s'"):format(get_release_dir(cmd)),
    ("url=$(curl -fsSL https://api.github.com/repos/%s/releases/latest | grep -oE 'https://[^\"]+%s' | head -n 1)"):format(
      release.repo,
      release.asset_pattern
    ),
  }
  vim.list_extend(steps, RELEASE_DOWNLOAD_STEPS)

  if release.wrapper then
    local wrapper_path = '"$dir/bin/' .. cmd .. '"'
    vim.list_extend(steps, {
      'mkdir -p "$dir/bin"',
      ('printf \'#!/bin/sh\\nexec %s "%%s" "$@"\\n\' "$dir/%s" > %s'):format(
        release.wrapper.runtime,
        release.wrapper.entry,
        wrapper_path
      ),
      'chmod +x ' .. wrapper_path,
    })
  end

  return table.concat(steps, ' && ')
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return string
local function select_instruction(dep, environment)
  local by_os = dep.os or {}

  for _, key in ipairs(OS_INSTRUCTION_KEYS[environment.os_name] or {}) do
    if by_os[key] ~= nil then return by_os[key] end
  end

  if dep.release and environment.os_name ~= OsNameEnum.windows then
    return build_release_command(dep.cmd, dep.release)
  end
  return dep.install_command or dep.cmd
end

---@param dep DepProps
---@param environment InstallEnvironmentProps
---@return string|nil command
---@return PackageManager|nil package_manager
local function build_install_command(dep, environment)
  local instruction = select_instruction(dep, environment)
  if instruction:find(SHELL_CHARACTERS_PATTERN) then return instruction, nil end
  if not environment.package_manager then return nil, nil end

  local resolution = environment.package_manager:resolve(
    instruction,
    environment.read_command_output,
    environment.confirm_install
  )
  if not resolution then return nil, nil end

  return resolution.package_manager:build_install_command(
    resolution.package_name
  ),
    resolution.package_manager
end

---@param deps DepProps[]
---@param environment? InstallEnvironmentProps
---@return DepProps[]
function M.find_missing(deps, environment)
  local active_environment = environment or get_live_environment()
  return vim.tbl_filter(
    function(dep)
      return not is_installed(dep, active_environment)
        or lacks_path_export(dep.push_env_source, active_environment.shell)
    end,
    filter_supported(deps, active_environment.os_name)
  )
end

---@param deps DepProps[]
function M.add_to_session_path(deps)
  for _, dep in ipairs(deps) do
    if dep.push_env_source then
      os_mod.add_to_path(os_mod.expand_home_path(dep.push_env_source))
    end
    if dep.release then
      os_mod.add_to_path(
        vim.fs.joinpath(
          get_release_dir(dep.cmd),
          dep.release.bin_subdir or 'bin'
        )
      )
    end
  end
end

---@param deps DepProps[]
---@param environment InstallEnvironmentProps
---@return InstallPlanDto
function M.plan(deps, environment)
  local plan = InstallPlanDto.new()
  local shell = environment.shell
  ---@type table<string, boolean>
  local exported_sources = {}

  for _, dep in ipairs(filter_supported(deps, environment.os_name)) do
    local command, package_manager = nil, nil
    local installed = is_installed(dep, environment)
    if not installed then
      command, package_manager = build_install_command(dep, environment)
    end

    local source = dep.push_env_source
    local exports_path = not exported_sources[source or '']
      and lacks_path_export(source, shell)

    if source and shell.rc_file and (command or installed and exports_path) then
      exported_sources[source] = true
      command = shell:append_env_source(
        command,
        source,
        (dep.lang or dep.cmd):upper(),
        exports_path
      )
    end

    if command then
      table.insert(plan.commands, command)
      plan.uses_package_manager = plan.uses_package_manager
        or package_manager ~= nil
    else
      table.insert(installed and plan.installed or plan.skipped, dep.cmd)
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
  local environment = get_live_environment()
  local plan = M.plan(deps, environment)

  if #plan.commands == 0 and #plan.skipped == 0 then
    vim.notify('All dependencies installed.', vim.log.levels.INFO)
    return
  end

  notify_plan(plan)
  if #plan.commands == 0 then return end

  environment.shell:run_in_terminal(plan.commands, function()
    os_mod.clear_cache()
    M.add_to_session_path(deps)
  end)
end

return M
