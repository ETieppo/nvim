---@type ThemeProps
local p = {
  bg = '#0c0d12',
  bg1 = '#11141d',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#8bc34a',
  ornamentActiveBg = '#243612',
  ornamentInactiveFg = '#4f7029',
  ornamentInactiveBg = '#141e0a',

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
  keyword = '#8bc34a',
  keywordAlt = '#c49a6c',
  func = '#584b00',
  types = '#7aa2f7',
  parameter = '#e0af68',
  property = '#A8B1D6',
  variable = '#c0caf5',
  constant = '#ffc777',
  builtin = '#0db9d7',
  strings = '#03826b',
  stringAlt = '#b4f9f8',
  comment = '#444b6a',
  tag = '#8bcFFF',
  tagAttr = '#556779',
}

require('theme.loader').load('kiwi', p)

return p
