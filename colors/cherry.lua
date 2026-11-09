---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#ffa3b5',
  ornamentActiveBg = '#3a1420',
  ornamentInactiveFg = '#b40032',
  ornamentInactiveBg = '#26081a',

  -- Errors / Diagnostics
  errorFg = '#d15583',
  errorBg = '#1a0100',
  warningFg = '#9c8700',
  warnBg = '#171000',
  infoFg = '#7dcfff',
  infoBg = '#00262f',
  successFg = '#85d0b7',
  successBg = '#0c1618',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#f50050',
  keywordAlt = '#542799',
  func = '#626a90',
  types = '#a60032',
  parameter = '#56708f',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#7e005e',
  builtin = '#c9e4ff',
  strings = '#727272',
  stringAlt = '#8fd4c0',
  comment = '#3d4357',
  tag = '#2a5f8a',
  tagAttr = '#556779',
}

require('theme.loader').load('cherry', p)

return p
