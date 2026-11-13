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
  errorFg = '#740024',
  errorBg = '#100707',
  warningFg = '#562d00',
  warnBg = '#0f0803',
  infoFg = '#072f5f',
  infoBg = '#050a11',
  hintFg = '#00424d',
  hintBg = '#020c0c',

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
