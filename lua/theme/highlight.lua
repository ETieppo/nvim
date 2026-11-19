local M = {}

local TOAST_LEVEL_COLOR_KEYS = {
  Error = 'errorFg',
  Warn = 'warningFg',
  Info = 'infoFg',
  Debug = 'debugFg',
  Success = 'hintFg',
  Trace = 'comment',
}
local DIAGNOSTIC_SEVERITY_COLOR_KEYS = {
  Error = { fg = 'errorFg', bg = 'errorBg' },
  Warn = { fg = 'warningFg', bg = 'warnBg' },
  Info = { fg = 'infoFg', bg = 'infoBg' },
  Hint = { fg = 'hintFg', bg = 'hintBg' },
  Ok = { fg = 'hintFg', bg = 'hintBg' },
}
local SLIMLINE_DIAGNOSTIC_SEVERITIES = { 'Error', 'Warn', 'Info', 'Hint' }
local SLIMLINE_MODES =
  { 'Normal', 'Insert', 'Visual', 'Replace', 'Command', 'Other' }
local SLIMLINE_COMPONENTS = { 'Git', 'Path', 'Filetype_lsp' }
local DAP_UI_INACTIVE_GROUPS = {
  'DapUINormalNC',
  'DapUIStepBackNC',
  'DapUIStepIntoNC',
  'DapUIStepOverNC',
  'DapUIStepOutNC',
  'DapUIRestartNC',
  'DapUIPlayPauseNC',
  'DapUIStopNC',
  'DapUIUnavailableNC',
}
local TODO_KEYWORD_COLOR_KEYS = {
  TODO = 'infoFg',
  FIX = 'errorFg',
  WARN = 'warningFg',
  NOTE = 'keyword',
  TEST = 'fg',
  PERF = 'func',
  HACK = 'keywordAlt',
}

local function invert_color(hex)
  local n = tonumber(hex:gsub('#', ''), 16)
  return string.format('#%06x', 0xFFFFFF - n)
end

---@param p ThemeProps
local function set_toast_highlights(p)
  for level, color_key in pairs(TOAST_LEVEL_COLOR_KEYS) do
    local color = p[color_key]
    vim.api.nvim_set_hl(
      0,
      'Toast' .. level .. 'Border',
      { fg = color, bg = p.bg1 }
    )
    vim.api.nvim_set_hl(
      0,
      'Toast' .. level .. 'Title',
      { fg = color, bg = p.bg1, bold = true }
    )
  end
end

---@param p ThemeProps
local function set_diagnostic_highlights(p)
  for severity, color_keys in pairs(DIAGNOSTIC_SEVERITY_COLOR_KEYS) do
    local fg, bg = p[color_keys.fg], p[color_keys.bg]
    vim.api.nvim_set_hl(0, 'Diagnostic' .. severity, { fg = fg })
    vim.api.nvim_set_hl(
      0,
      'DiagnosticUnderline' .. severity,
      { undercurl = true, sp = fg }
    )
    vim.api.nvim_set_hl(
      0,
      'DiagnosticVirtualText' .. severity,
      { fg = fg, bg = bg }
    )
  end
end

---@param p ThemeProps
local function set_dap_ui_inactive_highlights(p)
  for _, group in ipairs(DAP_UI_INACTIVE_GROUPS) do
    vim.api.nvim_set_hl(0, group, { bg = p.bg1 })
  end
end

---@param p ThemeProps
local function set_slimline_separator_highlights(p)
  local separator = { fg = p.bg2, bg = p.bg }
  local secondary_separator = { fg = p.bg2, bg = p.bg2 }

  for _, mode in ipairs(SLIMLINE_MODES) do
    vim.api.nvim_set_hl(0, 'SlimlineMode' .. mode .. 'Sep', separator)
    vim.api.nvim_set_hl(
      0,
      'SlimlineMode' .. mode .. 'Sep2Sec',
      secondary_separator
    )
  end
  vim.api.nvim_set_hl(0, 'SlimlineModeSecondarySep', separator)

  for _, component in ipairs(SLIMLINE_COMPONENTS) do
    vim.api.nvim_set_hl(0, 'Slimline' .. component .. 'PrimarySep', separator)
    vim.api.nvim_set_hl(
      0,
      'Slimline' .. component .. 'PrimarySep2Sec',
      secondary_separator
    )
    vim.api.nvim_set_hl(0, 'Slimline' .. component .. 'SecondarySep', separator)
  end

  for _, severity in ipairs(SLIMLINE_DIAGNOSTIC_SEVERITIES) do
    local color_keys = DIAGNOSTIC_SEVERITY_COLOR_KEYS[severity]
    local fg, bg = p[color_keys.fg], p[color_keys.bg]
    vim.api.nvim_set_hl(
      0,
      'SlimlineDiagnostics' .. severity,
      { fg = fg, bg = bg }
    )
    vim.api.nvim_set_hl(
      0,
      'SlimlineDiagnostics' .. severity .. 'Sep',
      { fg = bg, bg = p.bg }
    )
  end
end

---@param p ThemeProps
local function set_todo_highlights(p)
  for keyword, color_key in pairs(TODO_KEYWORD_COLOR_KEYS) do
    local color = p[color_key]
    vim.api.nvim_set_hl(0, 'TodoFg' .. keyword, { fg = color })
    vim.api.nvim_set_hl(
      0,
      'TodoBg' .. keyword,
      { fg = p.bg, bg = color, bold = true }
    )
    vim.api.nvim_set_hl(0, 'TodoSign' .. keyword, { fg = color })
  end
end

---@param p ThemeProps
function M.load(p)
  local set = vim.api.nvim_set_hl

  vim.opt.guicursor = {
    'n-v-c:block',
    'i-ci-ve:ver25',
    'r-cr:hor20',
    'a:Cursor',
  }

  set(0, 'Cursor', { fg = p.keyword, bg = invert_color(p.keyword) })
  set(0, 'TermCursor', { reverse = true })
  set(0, 'WinSeparator', { fg = p.bg })
  set(0, 'Normal', { fg = p.fg, bg = p.bg })
  set(0, 'NormalNC', { fg = p.fg, bg = p.bg })
  set(0, 'NormalFloat', { fg = p.fg, bg = p.ornamentActiveBg })
  set(0, 'CursorLine', { bg = p.bg1 })
  set(0, 'CursorLineNr', { fg = p.keyword, bold = false })
  set(0, 'LineNr', { fg = p.comment })
  set(0, 'NonText', { fg = p.ornamentInactiveFg })
  set(0, 'EndOfBuffer', { fg = p.bg })
  set(0, 'SignColumn', { fg = p.fg })
  set(0, 'Folded', { fg = p.fg, bg = p.bg2 })
  set(0, 'FoldColumn', { fg = p.fg })
  set(0, 'ColorColumn', { bg = p.bg })
  set(0, 'Conceal', { fg = p.keyword })
  set(0, 'MatchParen', { fg = p.keyword, bold = true })
  set(0, 'Search', { fg = p.bg, bg = p.keyword })
  set(0, 'IncSearch', { fg = p.fg, bg = p.fgDim })
  set(0, 'Visual', { bg = p.bg2 })
  set(0, 'Pmenu', { fg = p.fg, bg = p.bg1 })
  set(0, 'PmenuSel', { bg = p.bg2 })
  set(0, 'PmenuThumb', { bg = p.fg })
  set(0, 'TabLine', { fg = p.fg, bg = p.bg2 })
  set(0, 'TabLineSel', { fg = p.bg, bg = p.fg })
  set(0, 'TabLineFill', { bg = p.bg })
  set(0, 'VertSplit', { fg = p.bg2 })
  set(0, 'StatusLine', { fg = p.fg, bg = p.bg2 })
  set(0, 'StatusLineNC', { fg = p.fg, bg = p.bg1 })
  set(0, 'WinBar', { fg = p.fg, bg = p.bg, bold = true })
  set(0, 'WinBarNC', { fg = p.fg, bg = p.bg, bold = true })
  set(0, 'FloatBorder', { fg = p.bg2 })
  set(0, 'FloatShadow', { blend = 80 })
  set(0, 'FloatShadowThrough', { blend = 100 })
  set(0, 'Whitespace', { fg = p.bg2 })

  set(0, 'ToastBody', { fg = p.fg, bg = p.bg1 })
  set_toast_highlights(p)
  set(0, 'ErrorMsg', { fg = p.errorFg, bold = true })
  set(0, 'WarningMsg', { fg = p.warningFg })
  set(0, 'MoreMsg', { fg = p.infoFg })
  set(0, 'ModeMsg', { fg = p.ornamentActiveFg })
  set(0, 'Question', { fg = p.keywordAlt })
  set(0, 'MsgArea', { fg = p.fg, bg = p.bg })
  set(0, 'MsgSeparator', { fg = p.bg2, bg = p.bg })

  set(0, 'Comment', { fg = p.comment, italic = true })
  set(0, 'Keyword', { fg = p.keyword })
  set(0, 'Identifier', { fg = p.fg })
  set(0, 'Function', { fg = p.func })
  set(0, 'String', { fg = p.strings })
  set(0, 'Number', { fg = p.ornamentActiveFg })
  set(0, 'Boolean', { fg = p.tag })
  set(0, 'Float', { fg = p.keywordAlt })
  set(0, 'Type', { fg = p.types })
  set(0, 'Operator', { fg = p.ornamentActiveFg })
  set(0, 'Constant', { fg = p.constant })
  set(0, 'PreProc', { fg = p.fg })
  set(0, 'Special', { fg = p.fg })
  set(0, 'Statement', { fg = p.keyword })
  set(0, 'Conditional', { fg = p.keyword })
  set(0, 'Repeat', { fg = p.keyword })
  set(0, 'Label', { fg = p.types })
  set(0, 'Exception', { fg = p.errorFg })
  set(0, 'Include', { fg = p.fg })
  set(0, 'Define', { fg = p.fg })
  set(0, 'Macro', { fg = p.fg })
  set(0, 'StorageClass', { fg = p.keyword })
  set(0, 'Structure', { fg = p.types })
  set(0, 'Typedef', { fg = p.types })
  set(0, 'Title', { fg = p.types, bold = true })
  set(0, 'Underlined', { underline = true })
  set(0, 'Bold', { bold = true })
  set(0, 'Italic', { italic = true })
  set(0, 'Directory', { fg = p.fg })

  set_diagnostic_highlights(p)
  set(0, 'DiagnosticDeprecated', { strikethrough = true })

  set(0, 'DiffAdd', { bg = p.hintBg })
  set(0, 'DiffDelete', { bg = p.errorBg })
  set(0, 'DiffChange', { bg = p.warnBg })
  set(0, 'DiffText', { bg = p.bg2 })
  set(0, 'GitSignsAdd', { fg = p.hintFg })
  set(0, 'GitSignsChange', { fg = p.infoFg })
  set(0, 'GitSignsDelete', { fg = p.errorFg })
  set(0, 'GitSignsAddNr', { fg = p.hintFg })
  set(0, 'GitSignsChangeNr', { fg = p.infoFg })
  set(0, 'GitSignsDeleteNr', { fg = p.errorFg })
  set(0, 'GitSignsStagedAdd', { fg = p.hintFg })
  set(0, 'GitSignsStagedChange', { fg = p.infoFg })
  set(0, 'GitSignsStagedDelete', { fg = p.errorFg })

  set(0, '@namespace', { fg = p.fg })
  set(0, '@constructor', { fg = p.types })
  set(0, '@parameter', { fg = p.keywordAlt })
  set(0, '@operator', { fg = p.ornamentActiveFg })
  set(0, '@property', { fg = p.property })
  set(0, '@field', { fg = p.property })

  set(0, 'LspReferenceText', { bg = p.ornamentActiveBg })
  set(0, 'LspReferenceRead', { bg = p.ornamentActiveBg })
  set(0, 'LspReferenceWrite', { bg = p.ornamentActiveBg })
  set(0, 'LspCodeLens', { fg = p.fg })
  set(0, 'LspCodeLensSeparator', { fg = p.fg })
  set(0, 'LspInlayHint', { fg = p.fg, bg = p.ornamentActiveFg })
  set(0, 'LspSignatureActiveParameter', { fg = p.keyword, bold = true })
  set(0, 'LspFloatWinNormal', { bg = p.bg })
  set(0, 'LspFloatWinBorder', { fg = p.bg2 })
  set(0, 'LspTroubleNormal', { fg = p.fg, bg = p.bg })
  set(0, 'LspTroubleText', { fg = p.fg })
  set(0, 'LspTroubleCount', { fg = p.keywordAlt, bg = p.fg })

  set(0, '@variable', { fg = p.variable })
  set(0, '@variable.builtin', { fg = p.variable })
  set(0, '@variable.member', { fg = p.property })
  set(0, '@variable.parameter', { fg = p.keywordAlt })

  set(0, '@constant', { fg = p.constant })
  set(0, '@constant.builtin', { fg = p.keywordAlt, bold = true })
  set(0, '@constant.macro', { fg = p.fg })

  set(0, '@module', { fg = p.fg })
  set(0, '@module.builtin', { fg = p.fg, bold = true })

  set(0, '@function', { fg = p.func })
  set(0, '@function.builtin', { fg = p.builtin })
  set(0, '@function.call', { fg = p.func })
  set(0, '@function.macro', { fg = p.fg })
  set(0, '@function.method', { fg = p.func })
  set(0, '@function.method.call', { fg = p.func })

  set(0, '@keyword', { fg = p.keyword })
  set(0, '@keyword.function', { fg = p.keywordAlt })
  set(0, '@keyword.operator', { fg = p.ornamentActiveFg })
  set(0, '@keyword.return', { fg = p.keyword, italic = true })
  set(0, '@keyword.import', { fg = p.property })
  set(0, '@keyword.modifier', { fg = p.keyword })
  set(0, '@keyword.repeat', { fg = p.keyword })
  set(0, '@keyword.conditional', { fg = p.keyword })
  set(0, '@keyword.conditional.ternary', { fg = p.keyword })
  set(0, '@keyword.exception', { fg = p.errorFg })
  set(0, '@keyword.type', { fg = p.keywordAlt })

  set(0, '@string', { fg = p.strings })
  set(0, '@string.regex', { fg = p.builtin })
  set(0, '@string.regexp', { fg = p.builtin })
  set(0, '@string.escape', { fg = p.fg, bold = true })
  set(0, '@string.special', { fg = p.builtin })
  set(0, '@string.special.url', {
    fg = p.types,
    italic = true,
    underline = true,
  })
  set(0, '@string.special.path', { fg = p.types, italic = true })
  set(0, '@string.documentation', { fg = p.comment, italic = true })

  set(0, '@character', { fg = p.comment })
  set(0, '@character.special', { fg = p.builtin })

  set(0, '@number', { fg = p.ornamentActiveFg })
  set(0, '@number.float', { fg = p.ornamentActiveFg })

  set(0, '@punctuation.delimiter', { fg = p.ornamentActiveFg })
  set(0, '@punctuation.bracket', { fg = p.ornamentActiveFg })
  set(0, '@punctuation.special', { fg = p.ornamentActiveFg })
  set(0, '@punctuation.special.attribute', { fg = p.constant })

  set(0, '@attribute', { fg = p.fg })
  set(0, '@attribute.builtin', { fg = p.fg })

  set(0, '@comment', { fg = p.comment, italic = true })
  set(0, '@comment.note', { fg = p.bg, bg = p.infoFg })
  set(0, '@comment.todo', { fg = p.bg, bg = p.keyword })
  set(0, '@comment.warning', { fg = p.bg, bg = p.warningFg })
  set(0, '@comment.error', { fg = p.bg, bg = p.errorFg })
  set(0, '@comment.documentation', { fg = p.comment, italic = true })

  set(0, '@markup', { fg = p.fg })
  set(0, '@markup.heading', { fg = p.types, bold = true })
  set(0, '@markup.heading.1', { fg = p.types, bold = true })
  set(0, '@markup.heading.2', { fg = p.types, bold = true })
  set(0, '@markup.heading.3', { fg = p.func, bold = true })
  set(0, '@markup.heading.4', { fg = p.func, bold = true })
  set(0, '@markup.heading.5', { fg = p.property })
  set(0, '@markup.heading.6', { fg = p.fg })
  set(0, '@markup.strong', { fg = p.fg, bold = true })
  set(0, '@markup.italic', { italic = true })
  set(0, '@markup.strikethrough', { fg = p.fg, strikethrough = true })
  set(0, '@markup.link', { fg = p.func, bold = true })
  set(0, '@markup.link.url', { fg = p.types, underline = true })
  set(0, '@markup.link.label', { fg = p.property })
  set(0, '@markup.list', { fg = p.property })
  set(0, '@markup.list.checked', { fg = p.fg })
  set(0, '@markup.list.unchecked', { fg = p.keyword })
  set(0, '@markup.raw', { fg = p.fg, italic = true })
  set(0, '@markup.raw.block', { fg = p.fg })
  set(0, '@markup.quote', { fg = p.fg, italic = true })
  set(0, '@markup.math', { fg = p.property })

  set(0, '@type', { fg = p.types })
  set(0, '@type.builtin', { fg = p.builtin })
  set(0, '@type.definition', { fg = p.types, bold = true })
  set(0, '@type.qualifier', { fg = p.keyword })

  set(0, '@lsp.typemod.method.consuming', { italic = true })
  set(0, '@lsp.type.attribute', { fg = p.fg })
  set(0, '@lsp.type.derive', { fg = p.keywordAlt })
  set(0, '@lsp.type.attributeBracket', { fg = p.ornamentActiveFg })
  set(0, '@lsp.type.interface', { fg = p.fg })
  set(0, '@lsp.type.enum', { fg = p.types })
  set(0, '@lsp.type.enumMember', { fg = p.constant })
  set(0, '@lsp.type.struct', { fg = p.types })
  set(0, '@lsp.type.class', { fg = p.types })
  set(0, '@lsp.type.typeParameter', { fg = p.parameter })
  set(0, '@lsp.type.namespace', { fg = p.fg })
  set(0, '@lsp.type.macro', { fg = p.fg })
  set(0, '@lsp.type.variable', { link = '@variable' })
  set(0, '@lsp.type.parameter', { fg = p.variable })
  set(0, '@lsp.type.property', { fg = p.property })
  set(0, '@lsp.type.function', { link = '@function' })
  set(0, '@lsp.type.method', { link = '@function.method' })
  set(0, '@lsp.type.keyword', { link = '@keyword' })
  set(0, '@lsp.type.string', { link = '@string' })
  set(0, '@lsp.type.number', { link = '@number' })
  set(0, '@lsp.type.operator', { link = '@operator' })
  set(0, '@lsp.type.comment', { link = '@comment' })
  set(0, '@lsp.type.decorator', { fg = p.fg })
  set(0, '@lsp.type.event', { fg = p.constant })
  set(0, '@lsp.type.modifier', { fg = p.keyword })
  set(0, '@lsp.type.regexp', { fg = p.builtin })

  set(0, '@lsp.mod.deprecated', { strikethrough = true })
  set(0, '@lsp.mod.readonly', { fg = p.constant })
  set(0, '@lsp.mod.static', { fg = p.types, bold = true })

  set(0, '@tag', { fg = p.ornamentInactiveFg })
  set(0, '@tag.builtin', { fg = p.ornamentInactiveFg })
  set(0, '@tag.attribute', { fg = p.tagAttr, italic = true })
  set(0, '@tag.delimiter', { fg = p.fg })

  set(0, 'NeotestPassed', { fg = p.infoFg })
  set(0, 'NeotestFailed', { fg = p.errorFg })
  set(0, 'NeotestSkipped', { fg = p.keywordAlt })
  set(0, 'NeotestRunning', { fg = p.keyword })
  set(0, 'NeotestFocused', { underline = true })
  set(0, 'NeotestMarked', { fg = p.fg, bold = true })
  set(0, 'NeotestNamespace', { fg = p.fg })
  set(0, 'NeotestDir', { fg = p.fg })
  set(0, 'NeotestFile', { fg = p.fg })
  set(0, 'NeotestAdapterName', { fg = p.fg, bold = true })

  set(0, 'NeoTreeNormal', { fg = p.fg, bg = p.bg })
  set(0, 'NeoTreeTitleBar', { fg = p.bg, bg = p.fg })
  set(0, 'NeoTreeFloatTitle', { fg = p.fg })
  set(0, 'NeoTreeFileName', { fg = p.fg })
  set(0, 'NeoTreeFileNameOpened', { fg = p.fg })
  set(0, 'NeoTreeDirectoryName', { fg = p.fg })
  set(0, 'NeoTreeDirectoryIcon', { fg = p.ornamentInactiveFg })
  set(0, 'NeoTreeIndentMarker', { fg = p.bg2 })
  set(0, 'NeoTreeRootName', { fg = p.keyword, bold = true })
  set(0, 'NeoTreeFileStats', { fg = p.fg })
  set(0, 'NeoTreeFileStatsHeader', { fg = p.keyword, bold = true })
  set(0, 'NeoTreeDotfile', { fg = p.fg })
  set(0, 'NeoTreeSymbolicLinkTarget', { fg = p.fg })
  set(0, 'NeoTreeMessage', { fg = p.fg, italic = true })
  set(0, 'NeoTreeFadeText1', { fg = p.fg })
  set(0, 'NeoTreeFadeText2', { fg = p.bg2 })
  set(0, 'NeoTreeGitAdded', { fg = p.hintFg })
  set(0, 'NeoTreeGitModified', { fg = p.infoFg })
  set(0, 'NeoTreeGitDeleted', { fg = p.errorFg })
  set(0, 'NeoTreeGitUntracked', { fg = p.hintFg })
  set(0, 'NeoTreeGitIgnored', { fg = p.fgDim })
  set(0, 'NeoTreeGitConflict', { fg = p.warningFg, italic = true })
  set(0, 'NeoTreeTabActive', { bold = true })
  set(0, 'NeoTreeTabInactive', { fg = p.fg, bg = p.bg })
  set(0, 'NeoTreeTabSeparatorActive', { fg = p.bg })
  set(0, 'NeoTreeTabSeparatorInactive', { fg = p.bg, bg = p.bg1 })
  set(0, 'NeoTreeModified', { fg = p.infoFg })

  set(0, 'TelescopeBorder', { fg = p.bg1, bg = p.bg1 })
  set(0, 'TelescopePromptBorder', { fg = p.bg2, bg = p.bg2 })
  set(0, 'TelescopePromptNormal', { fg = p.fg, bg = p.bg2 })
  set(0, 'TelescopePromptPrefix', { fg = p.keyword, bg = p.bg2 })
  set(0, 'TelescopeNormal', { fg = 'NONE', bg = p.bg1 })
  set(
    0,
    'TelescopePreviewTitle',
    { fg = p.ornamentActiveFg, bg = p.ornamentActiveBg, bold = true }
  )
  set(
    0,
    'TelescopePromptTitle',
    { fg = p.ornamentInactiveFg, bg = p.ornamentInactiveBg, bold = true }
  )
  set(0, 'TelescopeResultsTitle', { fg = p.bg1, bg = p.bg1 })
  set(0, 'TelescopeSelection', { fg = 'NONE', bg = p.bg2 })
  set(0, 'TelescopePreviewLine', { fg = 'NONE', bg = p.ornamentActiveBg })
  set(0, 'TelescopeMatching', { fg = p.keyword, bold = true, italic = true })
  set(0, 'MusicPlaying', { fg = p.hintFg, bold = true })
  set(0, 'MusicSeparator', { fg = p.tag, bold = true })

  set_dap_ui_inactive_highlights(p)
  set(0, 'DapUIVariable', { fg = p.fg })
  set(0, 'DapUIValue', { fg = p.fg })
  set(0, 'DapUIModifiedValue', { fg = p.keyword, bold = true })
  set(0, 'DapUIScope', { fg = p.fg })
  set(0, 'DapUIBreakpointsPath', { fg = p.fg })
  set(0, 'DapUIBreakpointsInfo', { fg = p.fg })
  set(0, 'DapUIBreakpointsCurrentLine', { fg = p.keyword, bold = true })
  set(0, 'DapUIBreakpointsDisabledLine', { fg = p.fg })
  set(0, 'DapUIWatchesEmpty', { fg = p.errorFg })
  set(0, 'DapUIWatchesError', { fg = p.errorFg })
  set(0, 'DapUIWatchesValue', { fg = p.keywordAlt })
  set(0, 'DapUIStoppedThread', { fg = p.fg })
  set(0, 'DapUIDecoration', { fg = p.fg })
  set(0, 'DapBreak', { fg = p.errorFg })
  set(0, 'DapStop', { fg = p.fg })

  set(0, 'BlinkCmpKindDefault', { fg = p.fg })
  set(0, 'BlinkCmpKindSnippet', { fg = p.fg })
  set(0, 'BlinkCmpLabel', { fg = p.fg })
  set(0, 'BlinkCmpLabelMatch', { fg = p.keyword })
  set(0, 'BlinkCmpLabelDeprecated', { fg = p.fg, strikethrough = true })
  set(0, 'BlinkCmpDoc', { fg = p.fg, bg = p.bg })
  set(0, 'BlinkCmpDocBorder', { fg = p.bg2, bg = p.bg })

  set(0, 'Slimline', { fg = p.fg, bg = p.bg })
  set(0, 'SlimlineInactive', { fg = p.fg, bg = p.bg })
  set(0, 'SlimlineModeNormal', { fg = p.keyword, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeInsert', { fg = p.parameter, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeVisual', { fg = p.tag, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeReplace', { fg = p.keyword, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeCommand', { fg = p.fg, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeOther', { fg = p.fg, bg = p.bg2, bold = true })
  set(0, 'SlimlineModeSecondary', { fg = p.fg, bg = p.bg2 })
  set_slimline_separator_highlights(p)
  set(0, 'SlimlineGitPrimary', { fg = p.warningFg, bg = p.bg2 })
  set(0, 'SlimlineGitSecondary', { fg = p.fg, bg = p.bg2 })
  set(0, 'SlimlinePathPrimary', { fg = p.tag, bg = p.bg2 })
  set(0, 'SlimlinePathSecondary', { fg = p.fg, bg = p.bg2 })
  set(0, 'SlimlineFiletype_lspPrimary', { fg = p.fg, bg = p.bg2 })
  set(0, 'SlimlineFiletype_lspSecondary', { fg = p.fg, bg = p.bg2 })
  set(0, 'SlimlineDiagnosticsSecondary', { fg = p.fg, bg = p.bg2 })
  set(0, 'SlimlineDiagnosticsSecondarySep', { fg = p.bg2, bg = p.bg })

  set(0, 'Todo', { fg = p.bg, bg = p.infoFg })
  set_todo_highlights(p)

  set(0, 'SnacksImageMath', { fg = p.fg })
  set(0, 'SnacksIndent', { fg = p.fgDim })
  set(0, 'SnacksIndentScope', { fg = p.keyword })
  set(0, 'SnacksInputTitle', { link = 'NonText' })

  set(0, 'RedrawDebugNormal', { reverse = true })
  set(0, 'RedrawDebugClear', { bg = p.fg })
  set(0, 'RedrawDebugComposed', { bg = p.keyword })
  set(0, 'RedrawDebugRecompose', { bg = p.errorFg })

  set(0, 'WhichKeyNormal', { bg = p.bg1 })
  set(0, 'LazyNormal', { bg = p.bg1 })
end

return M
