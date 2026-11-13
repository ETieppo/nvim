---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#f0a830',
  ornamentActiveBg = '#3d2a0e',
  ornamentInactiveFg = '#8a3020',
  ornamentInactiveBg = '#24100a',

  -- Errors / Diagnostics
  errorFg = '#75002b',
  errorBg = '#150b0d',
  warningFg = '#5f2e00',
  warnBg = '#150c07',
  infoFg = '#083264',
  infoBg = '#090f16',
  hintFg = '#00424d',
  hintBg = '#051111',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#d48a12',
  keywordAlt = '#c2412a',
  func = '#3a6fb0',
  types = '#005f60',
  parameter = '#9a7ab8',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#7a3a1a',
  builtin = '#c8e4ff',
  strings = '#5a9a42',
  stringAlt = '#a6d68a',
  comment = '#3d4357',
  tag = '#8fd4c0',
  tagAttr = '#556779',
}

require('theme.loader').load('mango', p)

return p
