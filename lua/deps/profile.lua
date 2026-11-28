local helpers = require 'utils.helpers'
local M = {}
local statefile = vim.fs.joinpath(vim.fn.stdpath 'state', 'profile')
---@type string|nil
local profile_capability = nil

---@return string
local function read_profile_capability()
  if vim.fn.filereadable(statefile) == 0 then return 'minimal' end
  local lines = vim.fn.readfile(statefile)
  local name = (lines[1] and vim.trim(lines[1])) or ''
  return name ~= '' and name or 'max'
end

function M.get_profile_capability()
  if profile_capability == nil then
    profile_capability = read_profile_capability()
  end
  return profile_capability
end

function M.is_min_profile() return M.get_profile_capability() == 'minimal' end

function M.is_max_profile() return M.get_profile_capability() == 'max' end

function M.apply(name)
  if name == 'minimal' then
    vim.fn.delete(statefile)
  else
    vim.fn.writefile({ name }, statefile)
  end
  helpers.save_and_restart()
end

return M
