---@type ThemeProps
local p = {
  transparent = '#000000',
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  -- Errors / Diagnostics
  errorFg = '#f7768e',
  warningFg = '#e0af68',
  infoFg = '#7dcfff',
  successFg = '#85d0b7',
  infoBg = '#00262f',
  errorBg = '#160d0d',
  warnBg = '#15130a',
  successBg = '#0c1618',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#702ded',
  keywordAlt = '#e41951',
  func = '#7aa2f7',
  types = '#006573',
  parameter = '#3a5d81',
  property = '#A8B1D6',
  variable = '#c0caf5',
  constant = '#601D49',
  string_ = '#03826b',
  stringAlt = '#85d0b7',
  regex = '#b4f9f8',
  comment = '#444b6a',
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
