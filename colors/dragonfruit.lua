---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#e8358a',
  ornamentActiveBg = '#3f0f28',
  ornamentInactiveFg = '#1e7300',
  ornamentInactiveBg = '#001400',

  -- Errors / Diagnostics
  errorFg = '#e5534b',
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
  keyword = '#d92a7f',
  keywordAlt = '#8fcc3a',
  func = '#907987',
  types = '#0094b8',
  parameter = '#5a7aa8',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#6a2a7a',
  builtin = '#d6f0ff',
  strings = '#03826b',
  stringAlt = '#85d0b7',
  comment = '#3d4357',
  tag = '#FFF05f',
  tagAttr = '#556779',
}

require('theme.loader').load('dragonfruit', p)

return p
