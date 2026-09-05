local p = {
  -- neo-tree div line
  transparent = '#000000',
  --  buffer background, neo-tree inactive
  bg0 = '#000000',
  bg1 = '#0F0605',
  -- empty top line at neo-tree
  bg2 = '#08080b',
  -- selected line
  bg3 = '#0F0F15',
  bg4 = '#14141c',
  bg5 = '#1a1a26',
  bgBlue = '#11161f',
  bgGreen = '#0d1410',
  bgRed = '#160d0d',
  bgYellow = '#15130a',

  fg = '#a9b1d6',
  fgMuted = '#787c99',
  fgDim = '#2C4A5D',
  fgSemiHide = '#303040',
  fgBright = '#c5cae9',

  border = '#191921',
  borderFaint = '#14141a',
  borderFocus = '#545c7e',
  selection = '#3d59a144',
  selectionBg = '#FFFFFF',
  matchBg = '#3d59a166',

  -- selected line number, primary keywords, search match, wich-key key
  -- info
  keyword = '#F05239',
  keywordAlt = '#bb9af7',
  func = '#779310',
  funcBuiltin = '#0db9d7',
  type_ = '#0db9d7',
  typeParam = '#3a5d81',
  property = '#A8B1D6',
  namespace_ = '#FFFBDB',
  variable = '#c0caf5',
  param = '#e0687a',
  constant = '#b8003a',
  bracket = '#b8003a',
  constantAlt = '#c0768e',
  operator = '#93101B',
  string_ = '#03826b',
  stringAlt = '#85d0b7',
  regex = '#b4f9f8',
  number = '#c0768e',
  comment = '#444b6a',
  tag = '#892a3b',
  tagAttr = '#556779',
  macro = '#737aa2',

  error_ = '#f7768e',
  warning = '#e0af68',
  info = '#7aa2f7',
  hint = '#41a6b5',

  added = '#a9b1d6',
  modified = '#e0af68',
  deleted = '#f7768e',

  purple = '#934D10',
  salmon = '#e0687a',
  bgTeal = '#0c1618',
  teal = '#FFFBDB',
  cyanDim = '#00262f',
  cyan = '#7dcfff',
  cyanBright = '#b4f9f8',
  crimson = '#757575',
  crimsonBright = '#f7768e',
  darkRed = '#F05239',
  darkRedDim = '#290006',
}

require('settings.theme').load('pumpkin', p)

return p
