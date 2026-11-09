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
  errorFg = '#d15583',
  errorBg = '#1a0100',
  warningFg = '#9c8700',
  warnBg = '#171000',
  infoFg = '#7dcfff',
  infoBg = '#00262f',
  successFg = '#7ac46a',
  successBg = '#0e180b',

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
