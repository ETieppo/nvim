---@class PackageManagerProps
---@field name PackageManagerNameEnum
---@field install_args string[]
---@field requires_sudo boolean
---@field is_available boolean

---@class PackageManager : PackageManagerProps
local PackageManager = {}
PackageManager.__index = PackageManager

---@generic T : PackageManager
---@param self T
---@return T
function PackageManager:extend()
  local subclass = setmetatable({}, self)
  subclass.__index = subclass
  return subclass
end

---@generic T : PackageManager
---@param self T
---@param props PackageManagerProps
---@return T
function PackageManager:new(props)
  return setmetatable(vim.deepcopy(props), self)
end

---@param executable string
---@param use_sudo boolean
---@param packages string[]
---@return string
function PackageManager:build_invocation(executable, use_sudo, packages)
  local parts = use_sudo and { 'sudo', executable } or { executable }
  vim.list_extend(parts, self.install_args)
  vim.list_extend(parts, packages)
  return table.concat(parts, ' ')
end

---@param packages string[]
---@return string
function PackageManager:build_install_command(packages)
  return self:build_invocation(self.name, self.requires_sudo, packages)
end

---@return string[]
function PackageManager:get_bootstrap_commands() return {} end

return PackageManager
