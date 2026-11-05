---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#7dcfff',
  ornamentActiveBg = '#00262f',
  ornamentInactiveFg = '#94002F',
  ornamentInactiveBg = '#290006',

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
  keyword = '#702ded',
  keywordAlt = '#a2002e',
  func = '#2b4c9a',
  types = '#2596be',
  parameter = '#3a5d81',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#601D49',
  builtin = '#b4f9f8',
  strings = '#03826b',
  stringAlt = '#85d0b7',
  comment = '#3d4357',
  tag = '#892a3b',
  tagAttr = '#556779',
}

require('settings.theme').load('blackberry', p)

return p
