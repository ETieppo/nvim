---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#f2d94e',
  ornamentActiveBg = '#36300c',
  ornamentInactiveFg = '#8a4020',
  ornamentInactiveBg = '#24120a',

  -- Errors / Diagnostics
  errorFg = '#79002d',
  errorBg = '#100708',
  warningFg = '#542d00',
  warnBg = '#0f0803',
  infoFg = '#083264',
  infoBg = '#050a11',
  hintFg = '#00424d',
  hintBg = '#020c0d',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#d4b81e',
  keywordAlt = '#c45a2a',
  func = '#4a7ac8',
  types = '#2a9ab0',
  parameter = '#a07ac0',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#7a3a5a',
  builtin = '#d8d0ff',
  strings = '#03826b',
  stringAlt = '#85d0b7',
  comment = '#3d4357',
  tag = '#86001c',
  tagAttr = '#556779',
}

require('theme.loader').load('lemon', p)

return p
