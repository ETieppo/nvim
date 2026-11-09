---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#a6e22e',
  ornamentActiveBg = '#26360c',
  ornamentInactiveFg = '#7a6a2a',
  ornamentInactiveBg = '#1f1c08',

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
  keyword = '#8cc22a',
  keywordAlt = '#d4c55a',
  func = '#4a6bc4',
  types = '#2aa3b8',
  parameter = '#b06a8a',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#9a4a28',
  builtin = '#e6d0ff',
  strings = '#1f8f7a',
  stringAlt = '#8fd9c4',
  comment = '#3d4357',
  tag = '#2f2cec',
  tagAttr = '#556779',
}

require('theme.loader').load('lime', p)

return p
