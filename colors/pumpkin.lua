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
  errorFg = '#710029',
  errorBg = '#180407',
  warningFg = '#502d00',
  warnBg = '#120701',
  infoFg = '#00297c',
  infoBg = '#03091b',
  hintFg = '#00424d',
  hintBg = '#010d0e',

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
