---@type ThemeProps
local p = {
  bg = '#08080b',
  bg1 = '#0b0d16',
  bg2 = '#1a1a26',

  ornamentActiveFg = '#ff8a6a',
  ornamentActiveBg = '#3d221a',
  ornamentInactiveFg = '#9a3050',
  ornamentInactiveBg = '#260c16',

  -- Errors / Diagnostics
  errorFg = '#70003c',
  errorBg = '#0f0709',
  warningFg = '#5b3000',
  warnBg = '#0f0803',
  infoFg = '#072f5f',
  infoBg = '#050911',
  hintFg = '#00424d',
  hintBg = '#020b0c',

  fg = '#787c99',
  fgDim = '#303040',

  -- Syntax — Core
  keyword = '#ff461b',
  keywordAlt = '#d6406a',
  func = '#2a9aa0',
  types = '#6a8ae0',
  parameter = '#9a7ac0',
  property = '#7e86aa',
  variable = '#939cc5',
  constant = '#8a3a2a',
  builtin = '#bdeef5',
  strings = '#4f9a52',
  stringAlt = '#a6d69a',
  comment = '#3d4357',
  tag = '#00ecf3',
  tagAttr = '#556779',
}

require('theme.loader').load('peach', p)

return p
