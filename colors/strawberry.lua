---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#b3a6f2',
  ornamentActiveBg = '#1b1330',
  ornamentInactiveFg = '#2a7a99',
  ornamentInactiveBg = '#06171f',

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
  keyword = '#d1003f',
  keywordAlt = '#2a7a99',
  func = '#2b4c9a',
  types = '#5b84c4',
  parameter = '#8c4a78',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#6e1c3c',
  builtin = '#b8f5ea',
  strings = '#005600',
  stringAlt = '#9ee6d6',
  comment = '#658388',
  tag = '#a33a2c',
  tagAttr = '#556779',
}

require('theme.loader').load('strawberry', p)

return p
