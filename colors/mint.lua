---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#5fd4b0',
  ornamentActiveBg = '#0e3a2f',
  ornamentInactiveFg = '#9a2a48',
  ornamentInactiveBg = '#260a12',

  -- Errors / Diagnostics
  errorFg = '#70003c',
  errorBg = '#150b0e',
  warningFg = '#563000',
  warnBg = '#140d06',
  infoFg = '#242680',
  infoBg = '#0c0e16',
  hintFg = '#00424d',
  hintBg = '#061111',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#2fb08a',
  keywordAlt = '#d6305a',
  func = '#4a7ac8',
  types = '#7a8ae8',
  parameter = '#9a7ab0',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#5a2a5a',
  builtin = '#ffe0ec',
  strings = '#c8963a',
  stringAlt = '#ead2a0',
  comment = '#3d4357',
  tag = '#0192b7',
  tagAttr = '#556779',
}

require('theme.loader').load('mint', p)

return p
