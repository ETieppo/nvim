---@type ThemeProps
local p = {
  transparent = '#000000',
  bg = '#060609',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

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
  keywordAlt = '#e41951',
  func = '#2b4c9a',
  types = '#2596be',
  parameter = '#3a5d81',
  property = '#7e86aa',
  variable = '#00879a',
  constant = '#601D49',
  builtin = '#b4f9f8',
  string_ = '#03826b',
  stringAlt = '#85d0b7',
  regex = '#b4f9f8',
  comment = '#2f3548',
  tag = '#892a3b',
  tagAttr = '#556779',

  -- bracket and ornament
  ornamentActiveFg = '#7dcfff',
  ornamentActiveBg = '#00262f',
  ornamentInactiveFg = '#94002F',
  ornamentInactiveBg = '#290006',
}

require('settings.theme').load('blackberry', p)

return p
