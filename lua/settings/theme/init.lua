---@class ThemeProps
---@field bg string
---@field bg1 string
---@field bg2 string
---@field errorFg string
---@field warningFg string
---@field infoFg string
---@field successFg string
---@field infoBg string
---@field errorBg string
---@field warnBg string
---@field successBg string
---@field fg string
---@field fgDim string
---@field keyword string
---@field keywordAlt string
---@field func string
---@field types string
---@field parameter string
---@field property string
---@field variable string
---@field constant string
---@field strings string
---@field stringAlt string
---@field builtin string
---@field comment string
---@field tag string
---@field tagAttr string
---@field ornamentActiveFg string
---@field ornamentActiveBg string
---@field ornamentInactiveFg string
---@field ornamentInactiveBg string

local M = {}

---@type string|nil
M.name = nil
---@type ThemeProps|nil
M.palette = nil

---@param name string
---@param p ThemeProps
function M.load(name, p)
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

  M.name, M.palette = name, p
  vim.list_extend(p, { transparent = '#000000' })

  require('settings.theme.highlight').load(p)
  vim.g.colors_name = name
end

---@return ThemeProps|nil
function M.get() return M.palette end

---@return ThemeProps|nil
function M.get_theme_colors()
  local p = M.palette
  if not p then return nil end
  return p
end

return M
