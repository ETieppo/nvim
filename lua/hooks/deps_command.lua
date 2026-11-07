local helpers = require 'utils.helpers'
local FACE = '--_--'

---@class DepsUserCommandProps
---@field name string
---@field desc string
---@field subcommands table<string, CommandProps>
---@field target_name? string

---@class MissingDepsNotificationProps
---@field title string
---@field subject string
---@field missing_deps DepProps[]
---@field install_command string

local M = {}

---@param props DepsUserCommandProps
---@return string
local function build_usage(props)
  local usage = ':' .. props.name .. ' <command>'
  if props.target_name then
    usage = usage .. ' <' .. props.target_name .. '>'
  end
  return usage
end

---@param props DepsUserCommandProps
---@return fun(arg_lead: string, cmdline: string): string[]
local function build_subcommand_completion(props)
  return function(arg_lead, cmdline)
    if #vim.split(cmdline, '%s+') > 2 then return {} end

    local names = vim.tbl_keys(props.subcommands)
    table.sort(names)
    return vim.tbl_filter(
      ---@param name string
      ---@return boolean
      function(name) return vim.startswith(name, arg_lead) end,
      names
    )
  end
end

---@param props DepsUserCommandProps
function M.create_deps_user_command(props)
  vim.api.nvim_create_user_command(props.name, function(opts)
    local subcommand_name = opts.fargs[1]
    local target = opts.fargs[2]

    if subcommand_name == nil or (props.target_name and target == nil) then
      vim.notify('Not enough args\nUse ' .. build_usage(props) .. '\n' .. FACE)
      return
    end

    local subcommand =
      helpers.find_by_name_or_short(props.subcommands, subcommand_name)
    if subcommand == nil then
      vim.notify(
        'No '
          .. subcommand_name
          .. ' '
          .. props.name
          .. ' command found! '
          .. FACE
      )
      return
    end

    subcommand.run(target)
  end, {
    nargs = props.target_name and '+' or 1,
    desc = props.desc,
    complete = build_subcommand_completion(props),
  })
end

---@param props MissingDepsNotificationProps
function M.notify_missing_deps(props)
  if #props.missing_deps == 0 then return end

  local names = vim.tbl_map(
    ---@param dep DepProps
    ---@return string
    function(dep) return dep.cmd end,
    props.missing_deps
  )
  vim.notify(
    props.subject
      .. ' is missing deps:\n\n'
      .. table.concat(names, ',\n')
      .. '\n\nRun '
      .. props.install_command,
    vim.log.levels.WARN,
    { title = props.title }
  )
end

return M
