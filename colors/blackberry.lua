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
  errorFg = '#72002e',
  errorBg = '#100708',
  warningFg = '#582c00',
  warnBg = '#0f0804',
  infoFg = '#0d376a',
  infoBg = '#050a11',
  hintFg = '#00424d',
  hintBg = '#020c0d',

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

require('theme.loader').load('blackberry', p)

return p
