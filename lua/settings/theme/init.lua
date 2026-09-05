local M = {}

M.name = nil
M.palette = nil

---@param name string
---@param p table
function M.load(name, p)
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

  vim.o.termguicolors = true
  vim.g.colors_name = name
  M.name, M.palette = name, p

  require('settings.theme.highlight').load(p)
end

---@param name? string
---@return table|nil
function M.get(name)
  name = name or vim.g.colors_name
  if not name then return nil end
  if M.palette and M.name == name then return M.palette end

  local file =
    vim.api.nvim_get_runtime_file('colors/' .. name .. '.lua', false)[1]
  if not file then return nil end

  local ok, p = pcall(dofile, file)
  return ok and p or nil
end

function M.get_theme_colors()
  local p = M.get()
  if not p then return {} end

  return {
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
