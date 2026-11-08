---@type ThemeProps
local p = {
  bg = '#000000',
  bg1 = '#0F0F15',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#ff9e64',
  ornamentActiveBg = '#392013',
  ornamentInactiveFg = '#8a3a22',
  ornamentInactiveBg = '#0F0605',

  -- Errors / Diagnostics
  errorFg = '#f7768e',
  errorBg = '#160d0d',
  warningFg = '#e0af68',
  warnBg = '#15130a',
  infoFg = '#7aa2f7',
  infoBg = '#11161f',
  successFg = '#03826b',
  successBg = '#0d1410',

  fg = '#a9b1d6',
  fgDim = '#545470',

  -- Syntax — Core
  keyword = '#F05239',
  keywordAlt = '#ff9e64',
  func = '#f5a25d',
  types = '#7aa2f7',
  parameter = '#e0af68',
  property = '#A8B1D6',
  variable = '#c0caf5',
  constant = '#ffc777',
  builtin = '#0db9d7',
  strings = '#03826b',
  stringAlt = '#b4f9f8',
  comment = '#444b6a',
  tag = '#F05239',
  tagAttr = '#556779',
}

require('theme.loader').load('pumpkin', p)

return p
