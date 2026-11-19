---@type ThemeProps
local p = {
  bg = '#060609',
  bg1 = '#100c17',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#66d9ef',
  ornamentActiveBg = '#072e37',
  ornamentInactiveFg = '#3a5d81',
  ornamentInactiveBg = '#141931',

  errorFg = '#f7768e',
  errorBg = '#160d0d',
  warningFg = '#e0af68',
  warnBg = '#15130a',
  infoFg = '#7aa2f7',
  infoBg = '#11161f',
  hintFg = '#03826b',
  hintBg = '#0d1410',
  debugFg = '#bb9af7',

  fg = '#a9b1d6',
  fgDim = '#545470',

  keyword = '#66d9ef',
  keywordAlt = '#e41951',
  func = '#892a3b',
  types = '#4493f8',
  parameter = '#e0687a',
  property = '#A8B1D6',
  variable = '#c0caf5',
  constant = '#601D49',
  builtin = '#0db9d7',
  strings = '#03826b',
  comment = '#444b6a',
  tag = '#892a3b',
  tagAttr = '#556779',
}

require('theme.loader').load('blueberry', p)

return p
