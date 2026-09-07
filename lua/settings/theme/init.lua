local M = {}

M.name = nil
M.palette = nil

---@param name string
---@param p table
function M.load(name, p)
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

  vim.o.termguicolors = true
  M.name, M.palette = name, p

  require('settings.theme.highlight').load(p)
  vim.g.colors_name = name
end

---@return table|nil
function M.get() return M.palette end

---@return table|nil
function M.get_theme_colors()
  local p = M.palette
  if not p then return nil end

  return {
    bg0 = p.bg0,
    activeFg = p.cyan,
    activeBg = p.cyanDim,
    inactiveFg = p.darkRed,
    inactiveBg = p.darkRedDim,
    errorFg = p.error_,
    errorBg = p.bgRed,
    warnFg = p.warning,
    warnBg = p.bgYellow,
    infoFg = p.info,
    infoBg = p.bgBlue,
    hintFg = p.hint,
    hintBg = p.bgTeal,
  }
end

return M
