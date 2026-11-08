---@type ThemeProps
local p = {
  transparent = '#000000',
  bg = '#08080b',
  bg1 = '#0e0e12',
  bg2 = '#1a1a1d',

  -- Errors / Diagnostics
  errorFg = '#b8697f',
  errorBg = '#1a0d10',
  warningFg = '#a8966a',
  warnBg = '#171209',
  infoFg = '#7ba9a3',
  infoBg = '#0f1c1b',
  successFg = '#8abeb7',
  successBg = '#0e1615',

  fg = '#686868',
  fgDim = '#29292b',

  -- Syntax — Core
  keyword = '#95a7d0',
  keywordAlt = '#d1d6db',
  func = '#5378a2',
  types = '#74a4b4',
  parameter = '#5d7489',
  property = '#8f8f90',
  variable = '#b3c0cc',
  constant = '#6c6c93',
  builtin = '#c6e7e2',
  strings = '#5b8b84',
  stringAlt = '#8abeb7',
  comment = '#455665',
  tag = '#435a58',
  tagAttr = '#66798a',

  -- bracket and ornament
  ornamentActiveFg = '#7ba9a3',
  ornamentActiveBg = '#0f1c1b',
  ornamentInactiveFg = '#435a58',
  ornamentInactiveBg = '#101414',
}

require('theme.loader').load('midnight', p)

return p
