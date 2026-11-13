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
  errorFg = '#74003b',
  errorBg = '#150b0e',
  warningFg = '#533200',
  warnBg = '#130d06',
  infoFg = '#083264',
  infoBg = '#0a0f16',
  hintFg = '#00424d',
  hintBg = '#061112',

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
