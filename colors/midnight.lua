---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0e0e12',
  bg2 = '#1a1a1d',

  errorFg = '#b8697f',
  errorBg = '#1a0d10',
  warningFg = '#a8966a',
  warnBg = '#171209',
  infoFg = '#7ba9a3',
  infoBg = '#0f1c1b',
  hintFg = '#8abeb7',
  hintBg = '#0e1615',
  debugFg = '#9b8fbf',

  fg = '#686868',
  fgDim = '#29292b',

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
  comment = '#455665',
  tag = '#435a58',
  tagAttr = '#66798a',

  ornamentActiveFg = '#7ba9a3',
  ornamentActiveBg = '#174540',
  ornamentInactiveFg = '#435a58',
  ornamentInactiveBg = '#101414',
}

require('theme.loader').load('midnight', p)

return p
