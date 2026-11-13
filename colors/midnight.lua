---@type ThemeProps
local p = {
  transparent = '#000000',
  bg = '#08080b',
  bg1 = '#0e0e12',
  bg2 = '#1a1a1d',

  -- Errors / Diagnostics
  errorFg = '#631f34',
  errorBg = '#100708',
  warningFg = '#522e00',
  warnBg = '#0e0803',
  infoFg = '#083163',
  infoBg = '#050910',
  hintFg = '#00424d',
  hintBg = '#020b0c',

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
  ornamentActiveBg = '#174540',
  ornamentInactiveFg = '#435a58',
  ornamentInactiveBg = '#101414',
}

require('theme.loader').load('midnight', p)

return p
