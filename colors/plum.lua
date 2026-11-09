---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#8b9dbb',
  ornamentActiveBg = '#3a1226',
  ornamentInactiveFg = '#8a6020',
  ornamentInactiveBg = '#221707',

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
  keyword = '#a8336a',
  keywordAlt = '#d0902e',
  func = '#62738f',
  types = '#7a6ad0',
  parameter = '#5f8aa0',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#6a2a6a',
  builtin = '#ffd9a8',
  strings = '#03826b',
  stringAlt = '#85d0b7',
  comment = '#3d4357',
  tag = '#7dcfff',
  tagAttr = '#556779',
}

require('theme.loader').load('plum', p)

return p
