local M = {}

function M.load(p)
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then vim.cmd 'syntax reset' end

  vim.o.termguicolors = true
  local set = vim.api.nvim_set_hl

  -- ============================================================================
  -- UI / Editor
  -- ============================================================================
  set(0, 'WinSeparator', { fg = p.transparent })
  set(0, 'Normal', { fg = p.fg, bg = p.bg3 })
  set(0, 'NormalNC', { fg = p.fg, bg = p.bg2 })
  set(0, 'NormalFloat', { fg = p.fg, bg = p.bg3 })
  set(0, 'CursorLine', { bg = p.bg3 })
  set(0, 'CursorLineNr', { fg = p.keyword, bold = false })
  set(0, 'LineNr', { fg = p.fgDim })
  set(0, 'NonText', { fg = p.crimson })
  set(0, 'EndOfBuffer', { fg = p.bg3 })
  set(0, 'SignColumn', { fg = p.fg })
  set(0, 'Folded', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'FoldColumn', { fg = p.fgMuted })
  set(0, 'ColorColumn', { bg = p.bg4 })
  set(0, 'Conceal', { fg = p.bg5 })
  set(0, 'MatchParen', { fg = p.teal, bold = true })
  set(0, 'Search', { fg = p.bg1, bg = p.keyword })
  set(0, 'IncSearch', { fg = p.bg1, bg = p.teal })
  set(0, 'Visual', { bg = p.bg5 })
  set(0, 'Pmenu', { fg = p.fg, bg = p.bg3 })
  set(0, 'PmenuSel', { bg = p.bg4 })
  set(0, 'PmenuThumb', { bg = p.fgMuted })
  set(0, 'TabLine', { fg = p.fg, bg = p.bg4 })
  set(0, 'TabLineSel', { fg = p.bg2, bg = p.fgMuted })
  set(0, 'TabLineFill', { bg = p.bg2 })
  set(0, 'VertSplit', { fg = p.bg5 })
  set(0, 'StatusLine', { fg = p.fg, bg = p.bg4 })
  set(0, 'StatusLineNC', { fg = p.fgDim, bg = p.bg3 })
  set(0, 'WinBar', { fg = p.fgMuted, bg = p.bg0, bold = true })
  set(0, 'WinBarNC', { fg = p.fgMuted, bg = p.bg0, bold = true })
  set(0, 'FloatBorder', { fg = p.bg5 })
  set(0, 'FloatShadow', { blend = 80 })
  set(0, 'FloatShadowThrough', { blend = 100 })
  set(0, 'Cursor', { fg = p.bg3, bg = p.teal })
  set(0, 'TermCursor', { reverse = true })
  set(0, 'Whitespace', { fg = p.bg5 })

  -- ============================================================================
  -- Syntax (fallback sem Treesitter)
  -- ============================================================================
  set(0, 'Comment', { fg = p.comment, italic = true })
  set(0, 'Keyword', { fg = p.keyword })
  set(0, 'Identifier', { fg = p.fg })
  set(0, 'Function', { fg = p.func })
  set(0, 'String', { fg = p.string_ })
  set(0, 'Number', { fg = p.number })
  set(0, 'Boolean', { fg = p.constantAlt })
  set(0, 'Float', { fg = p.number })
  set(0, 'Type', { fg = p.type_ })
  set(0, 'Operator', { fg = p.operator })
  set(0, 'Constant', { fg = p.constant })
  set(0, 'PreProc', { fg = p.macro })
  set(0, 'Special', { fg = p.macro })
  set(0, 'Statement', { fg = p.keyword })
  set(0, 'Conditional', { fg = p.keyword })
  set(0, 'Repeat', { fg = p.keyword })
  set(0, 'Label', { fg = p.type_ })
  set(0, 'Exception', { fg = p.crimsonBright })
  set(0, 'Include', { fg = p.fgMuted })
  set(0, 'Define', { fg = p.fgMuted })
  set(0, 'Macro', { fg = p.macro })
  set(0, 'StorageClass', { fg = p.keyword })
  set(0, 'Structure', { fg = p.type_ })
  set(0, 'Typedef', { fg = p.type_ })
  set(0, 'Title', { fg = p.type_, bold = true })
  set(0, 'Underlined', { underline = true })
  set(0, 'Bold', { bold = true })
  set(0, 'Italic', { italic = true })
  set(0, 'Directory', { fg = p.macro })

  -- ============================================================================
  -- Diagnostic
  -- ============================================================================
  set(0, 'DiagnosticError', { fg = p.error_ })
  set(0, 'DiagnosticWarn', { fg = p.warning })
  set(0, 'DiagnosticInfo', { fg = p.info })
  set(0, 'DiagnosticHint', { fg = p.hint })
  set(0, 'DiagnosticOk', { fg = p.hint })
  set(0, 'DiagnosticUnderlineError', { undercurl = true, sp = p.error_ })
  set(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = p.warning })
  set(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = p.info })
  set(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = p.hint })
  set(0, 'DiagnosticUnderlineOk', { undercurl = true, sp = p.hint })
  set(0, 'DiagnosticVirtualTextError', { fg = p.error_, bg = p.bgRed })
  set(0, 'DiagnosticVirtualTextWarn', { fg = p.warning, bg = p.bgYellow })
  set(0, 'DiagnosticVirtualTextInfo', { fg = p.info, bg = p.bgBlue })
  set(0, 'DiagnosticVirtualTextHint', { fg = p.hint, bg = p.bgGreen })
  set(0, 'DiagnosticVirtualTextOk', { fg = p.hint, bg = p.bgGreen })
  set(0, 'DiagnosticDeprecated', { strikethrough = true })

  -- ============================================================================
  -- Git / Diff
  -- ============================================================================
  set(0, 'DiffAdd', { bg = p.bgGreen })
  set(0, 'DiffDelete', { bg = p.bgRed })
  set(0, 'DiffChange', { bg = p.bgYellow })
  set(0, 'DiffText', { bg = p.bg5 })
  set(0, 'GitSignsAdd', { fg = p.added })
  set(0, 'GitSignsChange', { fg = p.modified })
  set(0, 'GitSignsDelete', { fg = p.deleted })
  set(0, 'GitSignsAddNr', { fg = p.added })
  set(0, 'GitSignsChangeNr', { fg = p.modified })
  set(0, 'GitSignsDeleteNr', { fg = p.deleted })
  set(0, 'GitSignsStagedAdd', { fg = p.added })
  set(0, 'GitSignsStagedChange', { fg = p.modified })
  set(0, 'GitSignsStagedDelete', { fg = p.deleted })

  -- ============================================================================
  -- LSP
  -- ============================================================================
  set(0, 'LspReferenceText', { bg = p.bg4 })
  set(0, 'LspReferenceRead', { bg = p.bg4 })
  set(0, 'LspReferenceWrite', { bg = p.bg4 })
  set(0, 'LspCodeLens', { fg = p.fgMuted })
  set(0, 'LspCodeLensSeparator', { fg = p.fgMuted })
  set(0, 'LspInlayHint', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'LspSignatureActiveParameter', { fg = p.teal, bold = true })
  set(0, 'LspFloatWinNormal', { bg = p.bg2 })
  set(0, 'LspFloatWinBorder', { fg = p.bg5 })
  set(0, 'LspSagaHoverBorder', { fg = p.fgMuted })
  set(0, 'LspSagaSignatureHelpBorder', { fg = p.crimsonBright })
  set(0, 'LspSagaCodeActionBorder', { fg = p.fgMuted })
  set(0, 'LspSagaRenameBorder', { fg = p.fgMuted })
  set(0, 'LspSagaDefPreviewBorder', { fg = p.fgMuted })
  set(0, 'LspSagaFinderSelection', { fg = p.bg4 })
  set(0, 'LspTroubleNormal', { fg = p.fgMuted, bg = p.bg2 })
  set(0, 'LspTroubleText', { fg = p.fg })
  set(0, 'LspTroubleCount', { fg = p.purple, bg = p.fgMuted })

  -- ============================================================================
  -- Treesitter & Semantic Tokens
  -- ============================================================================

  -- ── Variables ────────────────────────────────────────────────────────────────

  set(0, '@variable', { fg = p.variable })
  set(0, '@variable.builtin', { fg = p.variable }) -- self (no Zed = variable color)
  set(0, '@variable.member', { fg = p.property }) -- field access: foo.bar
  set(0, '@variable.parameter', { fg = p.param }) -- na definição fn f(x: ...)

  -- ── Constants ────────────────────────────────────────────────────────────────
  set(0, '@constant', { fg = p.constant })
  set(0, '@constant.builtin', { fg = p.constantAlt, bold = true })
  set(0, '@constant.macro', { fg = p.macro })

  -- ── Namespaces / modules ─────────────────────────────────────────────────────
  set(0, '@module', { fg = p.namespace_ })
  set(0, '@module.builtin', { fg = p.namespace_, bold = true })
  set(0, '@namespace', { fg = p.namespace_ })

  -- ── Functions ────────────────────────────────────────────────────────────────
  set(0, '@function', { fg = p.func })
  set(0, '@function.builtin', { fg = p.funcBuiltin })
  set(0, '@function.call', { fg = p.func })
  set(0, '@function.macro', { fg = p.macro })
  set(0, '@function.method', { fg = p.func })
  set(0, '@function.method.call', { fg = p.func })
  set(0, '@constructor', { fg = p.type_ })

  -- ── Parameters ───────────────────────────────────────────────────────────────
  set(0, '@parameter', { fg = p.param })

  -- ── Keywords ─────────────────────────────────────────────────────────────────
  set(0, '@keyword', { fg = p.keyword })
  set(0, '@keyword.function', { fg = p.keywordAlt })
  set(0, '@keyword.operator', { fg = p.operator })
  set(0, '@keyword.return', { fg = p.keyword, italic = true })
  set(0, '@keyword.import', { fg = p.property })
  set(0, '@keyword.modifier', { fg = p.keyword })
  set(0, '@keyword.repeat', { fg = p.keyword })
  set(0, '@keyword.conditional', { fg = p.keyword })
  set(0, '@keyword.conditional.ternary', { fg = p.keyword })
  set(0, '@keyword.exception', { fg = p.crimsonBright })
  set(0, '@keyword.type', { fg = p.keywordAlt })

  -- ── Types ────────────────────────────────────────────────────────────────────
  set(0, '@type', { fg = p.type_ })
  set(0, '@type.builtin', { fg = p.funcBuiltin })
  set(0, '@type.definition', { fg = p.type_, bold = true })
  set(0, '@type.qualifier', { fg = p.keyword })

  -- ── Properties / fields ──────────────────────────────────────────────────────

  set(0, '@property', { fg = p.property })
  set(0, '@field', { fg = p.property })

  -- ── Strings ──────────────────────────────────────────────────────────────────
  set(0, '@string', { fg = p.string_ })
  set(0, '@string.regex', { fg = p.regex })
  set(0, '@string.regexp', { fg = p.regex })
  set(0, '@string.escape', { fg = p.macro, bold = true })
  set(0, '@string.special', { fg = p.regex })
  set(0, '@string.special.url', {
    fg = p.cyan,
    italic = true,
    underline = true,
  })
  set(0, '@string.special.path', { fg = p.cyan, italic = true })
  set(0, '@string.documentation', { fg = p.stringAlt, italic = true })

  set(0, '@character', { fg = p.stringAlt })
  set(0, '@character.special', { fg = p.regex })
  set(0, '@number', { fg = p.number })
  set(0, '@number.float', { fg = p.number })

  set(0, '@operator', { fg = p.operator })

  set(0, '@punctuation.delimiter', { fg = p.fg })
  set(0, '@punctuation.bracket', { fg = p.bracket })
  set(0, '@punctuation.special', { fg = p.bracket})

  set(0, '@attribute', { fg = p.macro })
  set(0, '@attribute.builtin', { fg = p.macro })
  set(0, '@punctuation.special.attribute', { fg = p.constant })
  set(0, '@lsp.type.attribute', { fg = p.macro })
  set(0, '@lsp.type.derive', { fg = p.funcBuiltin })
  set(0, '@lsp.type.attributeBracket', { fg = p.bracket })

  set(0, '@comment', { fg = p.comment, italic = true })
  set(0, '@comment.note', { fg = p.bg2, bg = p.info })
  set(0, '@comment.todo', { fg = p.bg2, bg = p.teal })
  set(0, '@comment.warning', { fg = p.bg2, bg = p.warning })
  set(0, '@comment.error', { fg = p.bg2, bg = p.error_ })
  set(0, '@comment.documentation', { fg = p.stringAlt, italic = true })

  set(0, '@markup', { fg = p.fg })
  set(0, '@markup.heading', { fg = p.type_, bold = true })
  set(0, '@markup.heading.1', { fg = p.type_, bold = true })
  set(0, '@markup.heading.2', { fg = p.type_, bold = true })
  set(0, '@markup.heading.3', { fg = p.func, bold = true })
  set(0, '@markup.heading.4', { fg = p.func, bold = true })
  set(0, '@markup.heading.5', { fg = p.property })
  set(0, '@markup.heading.6', { fg = p.fgMuted })
  set(0, '@markup.strong', { fg = p.fgBright, bold = true })
  set(0, '@markup.italic', { italic = true })
  set(0, '@markup.strikethrough', { fg = p.fg, strikethrough = true })
  set(0, '@markup.link', { fg = p.func, bold = true })
  set(0, '@markup.link.url', { fg = p.cyan, underline = true })
  set(0, '@markup.link.label', { fg = p.property })
  set(0, '@markup.list', { fg = p.property })
  set(0, '@markup.list.checked', { fg = p.fg })
  set(0, '@markup.list.unchecked', { fg = p.teal })
  set(0, '@markup.raw', { fg = p.macro, italic = true })
  set(0, '@markup.raw.block', { fg = p.fgMuted })
  set(0, '@markup.quote', { fg = p.fgMuted, italic = true })
  set(0, '@markup.math', { fg = p.property })

  set(0, '@lsp.type.interface', { fg = p.macro })
  set(0, '@lsp.type.enum', { fg = p.type_ })
  set(0, '@lsp.type.enumMember', { fg = p.constant })
  set(0, '@lsp.type.struct', { fg = p.type_ })
  set(0, '@lsp.type.class', { fg = p.type_ })
  set(0, '@lsp.type.typeParameter', { fg = p.typeParam })
  set(0, '@lsp.type.namespace', { fg = p.namespace_ })
  set(0, '@lsp.type.macro', { fg = p.macro })
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
  set(0, '@lsp.type.decorator', { fg = p.macro })
  set(0, '@lsp.type.event', { fg = p.constant })
  set(0, '@lsp.type.modifier', { fg = p.keyword })
  set(0, '@lsp.type.regexp', { fg = p.regex })
  set(0, '@lsp.mod.deprecated', { strikethrough = true })
  set(0, '@lsp.mod.readonly', { fg = p.constant })
  set(0, '@lsp.mod.static', { fg = p.type_, bold = true })

  -- ── Tags (HTML/JSX/TSX/XML) ───────────────────────────────────────────────────
  set(0, '@tag', { fg = p.tag })
  set(0, '@tag.builtin', { fg = p.tag })
  set(0, '@tag.attribute', { fg = p.tagAttr, italic = true })
  set(0, '@tag.delimiter', { fg = p.fgDim })

  -- ── rust ─────────────────────────────────
  set(0, '@lsp.type.selfKeyword', { fg = p.keyword, italic = true })
  set(0, '@lsp.type.selfTypeKeyword', { fg = p.type_ })
  set(0, '@lsp.type.builtinType', { fg = p.type_ })
  set(0, '@lsp.type.builtinAttribute', { fg = p.macro })
  set(0, '@lsp.type.lifetime', { fg = p.typeParam })
  set(0, '@lsp.type.generic', { fg = p.typeParam })
  set(0, '@lsp.type.typeAlias', { fg = p.type_ })
  set(0, '@lsp.type.const', { fg = p.constant })
  set(0, '@lsp.type.static', { fg = p.constant })
  set(0, '@lsp.type.formatSpecifier', { fg = p.regex })
  set(0, '@lsp.type.boolean', { fg = p.constantAlt })
  set(
    0,
    '@lsp.type.unresolvedReference',
    { undercurl = true, sp = p.stringAlt }
  )
  set(0, '@lsp.typemod.const.constant', { fg = p.constant })
  set(0, '@lsp.typemod.const.declaration', { fg = p.constant })
  set(0, '@lsp.typemod.variable.static', { fg = p.constant })
  set(0, '@lsp.typemod.variable.readonly', { fg = p.constant })
  set(0, '@lsp.typemod.variable.mutable', { fg = p.variable, underline = true })
  set(0, '@lsp.typemod.parameter.mutable', { fg = p.param, underline = true })
  set(0, '@lsp.typemod.variable.callable', { fg = p.func })
  set(0, '@lsp.typemod.variable.constant', { fg = p.constant })
  set(
    0,
    '@lsp.typemod.selfKeyword.defaultLibrary',
    { fg = p.keyword, italic = true }
  )
  set(0, '@lsp.typemod.function.defaultLibrary', { fg = p.funcBuiltin })
  set(0, '@lsp.typemod.method.defaultLibrary', { fg = p.funcBuiltin })
  set(0, '@lsp.typemod.macro.defaultLibrary', { fg = p.macro, bold = true })
  set(0, '@lsp.typemod.type.defaultLibrary', { fg = p.funcBuiltin })
  set(0, '@lsp.typemod.struct.defaultLibrary', { fg = p.funcBuiltin })
  set(0, '@lsp.typemod.enum.defaultLibrary', { fg = p.funcBuiltin })
  set(
    0,
    '@lsp.typemod.enumMember.defaultLibrary',
    { fg = p.constantAlt, bold = true }
  )
  set(0, '@lsp.typemod.interface.defaultLibrary', { fg = p.funcBuiltin })
  set(0, '@lsp.typemod.property.defaultLibrary', { fg = p.property })
  set(0, '@lsp.typemod.attributeBracket.attribute', { fg = p.bracket })
  set(0, '@lsp.typemod.decorator.attribute', { fg = p.macro })

  -- Neotest
  set(0, 'NeotestPassed', { fg = p.added })
  set(0, 'NeotestFailed', { fg = p.error_ })
  set(0, 'NeotestSkipped', { fg = p.purple })
  set(0, 'NeotestRunning', { fg = p.teal })
  set(0, 'NeotestFocused', { underline = true })
  set(0, 'NeotestMarked', { fg = p.fg, bold = true })
  set(0, 'NeotestNamespace', { fg = p.namespace_ })
  set(0, 'NeotestDir', { fg = p.namespace_ })
  set(0, 'NeotestFile', { fg = p.namespace_ })
  set(0, 'NeotestAdapterName', { fg = p.fgMuted, bold = true })

  -- Neo-tree
  set(0, 'NeoTreeNormal', { fg = p.fg, bg = p.bg2 })
  set(0, 'NeoTreeTitleBar', { fg = p.bg2, bg = p.fgMuted })
  set(0, 'NeoTreeFloatTitle', { fg = p.fg })
  set(0, 'NeoTreeFileName', { fg = p.fgMuted })
  set(0, 'NeoTreeFileNameOpened', { fg = p.fg })
  set(0, 'NeoTreeDirectoryName', { fg = p.namespace_ })
  set(0, 'NeoTreeDirectoryIcon', { fg = p.crimson })
  set(0, 'NeoTreeIndentMarker', { fg = p.bg5 })
  set(0, 'NeoTreeRootName', { fg = p.teal, bold = true })
  set(0, 'NeoTreeFileStats', { fg = p.fgMuted })
  set(0, 'NeoTreeFileStatsHeader', { fg = p.teal, bold = true })
  set(0, 'NeoTreeDotfile', { fg = p.macro })
  set(0, 'NeoTreeSymbolicLinkTarget', { fg = p.fgMuted })
  set(0, 'NeoTreeMessage', { fg = p.fgMuted, italic = true })
  set(0, 'NeoTreeFadeText1', { fg = p.fgMuted })
  set(0, 'NeoTreeFadeText2', { fg = p.bg5 })
  set(0, 'NeoTreeGitAdded', { fg = p.added })
  set(0, 'NeoTreeGitModified', { fg = p.modified })
  set(0, 'NeoTreeGitDeleted', { fg = p.deleted })
  set(0, 'NeoTreeGitUntracked', { fg = p.purple })
  set(0, 'NeoTreeGitIgnored', { fg = p.fgSemiHide })
  set(0, 'NeoTreeGitConflict', { fg = p.warning, italic = true })
  set(0, 'NeoTreeTabActive', { bold = true })
  set(0, 'NeoTreeTabInactive', { fg = p.fgMuted, bg = p.bg1 })
  set(0, 'NeoTreeTabSeparatorActive', { fg = p.bg2 })
  set(0, 'NeoTreeTabSeparatorInactive', { fg = p.bg2, bg = p.bg3 })
  set(0, 'NeoTreeModified', { fg = p.modified })

  -- NvimTree
  set(0, 'NvimTreeNormal', { fg = p.fg, bg = p.bg2 })
  set(0, 'NvimTreeFolderName', { fg = p.namespace_ })
  set(0, 'NvimTreeFolderIcon', { fg = p.namespace_ })
  set(0, 'NvimTreeOpenedFolderName', { fg = p.namespace_ })
  set(0, 'NvimTreeOpenedFile', { fg = p.fgMuted })
  set(0, 'NvimTreeEmptyFolderName', { fg = p.fgMuted })
  set(0, 'NvimTreeIndentMarker', { fg = p.bg5 })
  set(0, 'NvimTreeRootFolder', { fg = p.teal, bold = true })
  set(0, 'NvimTreeSymlink', { fg = p.fgMuted })
  set(0, 'NvimTreeSpecialFile', { fg = p.macro })
  set(0, 'NvimTreeImageFile', { fg = p.fg })
  set(0, 'NvimTreeGitNew', { fg = p.added })
  set(0, 'NvimTreeGitDirty', { fg = p.modified })
  set(0, 'NvimTreeGitDeleted', { fg = p.deleted })
  set(0, 'NvimTreeGitMerge', { fg = p.modified })

  -- Telescope
  set(0, 'TelescopeBorder', { fg = p.fgSemiHide, bg = p.bg3 })
  set(0, 'TelescopeSelectionCaret', { fg = p.teal })
  set(0, 'TelescopeSelection', { fg = p.fg, bg = p.bg4 })

  set(0, 'TelescopeNormal', { bg = p.bg3 })
  set(0, 'TelescopePreviewDate', {})
  set(0, 'TelescopePreviewGroup', {})
  set(0, 'TelescopePreviewUser', {})
  set(0, 'TelescopePreviewHyphen', {})
  set(0, 'TelescopePreviewExecute', {})
  set(0, 'TelescopePreviewWrite', {})
  set(0, 'TelescopePreviewRead', {})
  set(0, 'TelescopePreviewSocket', {})
  set(0, 'TelescopePreviewLink', {})
  set(0, 'TelescopePreviewBlock', {})
  set(0, 'TelescopePreviewDirectory', {})
  set(0, 'TelescopePreviewCharDev', {})
  set(0, 'TelescopePreviewPipe', {})
  set(0, 'TelescopePreviewMatch', {})
  set(0, 'TelescopePreviewLine', {})
  set(0, 'TelescopePromptPrefix', {})
  set(0, 'TelescopeMatching', { bg = p.fgDim })
  set(0, 'TelescopePromptCounter', {})
  set(0, 'TelescopeMultiIcon', {})
  set(0, 'TelescopeMultiSelection', {})
  set(0, 'TelescopeResultsDiffUntracked', {})
  set(0, 'TelescopeResultsDiffDelete', {})
  set(0, 'TelescopeResultsDiffAdd', {})
  set(0, 'TelescopeResultsDiffChange', {})
  set(0, 'TelescopeResultsSpecialComment', {})
  set(0, 'TelescopePreviewSticky', {})
  set(0, 'TelescopeResultsComment', {})
  set(0, 'TelescopeResultsNumber', {})
  set(0, 'TelescopeResultsIdentifier', {})
  set(0, 'TelescopeResultsLineNr', {})
  set(0, 'TelescopeResultsVariable', {})
  set(0, 'TelescopePreviewSize', {})
  set(0, 'TelescopeResultsStruct', {})
  set(0, 'TelescopeResultsOperator', {})
  set(0, 'TelescopeResultsMethod', {})
  set(0, 'TelescopeResultsFunction', {})
  set(0, 'TelescopeResultsField', {})
  set(0, 'TelescopeResultsConstant', {})
  set(0, 'TelescopeResultsClass', {})
  set(0, 'TelescopePreviewMessageFillchar', {})

  -- Dashboard / Alpha
  set(0, 'AlphaHeader', { fg = p.teal })
  set(0, 'AlphaFooter', { fg = p.namespace_ })
  set(0, 'AlphaButtons', { fg = p.namespace_ })
  set(0, 'AlphaShortcut', { fg = p.teal })
  set(0, 'AlphaHeaderLabel', { fg = p.teal })
  set(0, 'DashboardFooter', { fg = p.teal, italic = true })

  -- Mini
  set(0, 'MiniStarterQuery', { fg = p.fg })
  set(0, 'MiniStarterItemPrefix', { fg = p.fgMuted })
  set(0, 'MiniStarterItemBullet', { fg = p.fgMuted })
  set(0, 'MiniStarterSection', { fg = p.keyword })
  set(0, 'MiniStarterFooter', { fg = p.teal, italic = true })
  set(0, 'MiniStarterCurrent', { nocombine = true })
  set(0, 'MiniStatuslineModeNormal', {
    fg = p.bg1,
    bg = p.teal,
    bold = true,
  })
  set(
    0,
    'MiniStatuslineModeInsert',
    { fg = p.bg1, bg = p.typeParam, bold = true }
  )
  set(0, 'MiniStatuslineModeVisual', {
    fg = p.bg1,
    bg = p.purple,
    bold = true,
  })
  set(0, 'MiniStatuslineModeReplace', {
    fg = p.bg1,
    bg = p.keyword,
    bold = true,
  })
  set(
    0,
    'MiniStatuslineModeCommand',
    { fg = p.bg1, bg = p.namespace_, bold = true }
  )
  set(
    0,
    'MiniStatuslineModeOther',
    { fg = p.bg1, bg = p.namespace_, bold = true }
  )
  set(0, 'MiniStatuslineDevinfo', { fg = p.fg, bg = p.bg4 })
  set(0, 'MiniStatuslineFileinfo', { fg = p.fg, bg = p.bg4 })
  set(0, 'MiniTablineCurrent', { fg = p.fg, bg = p.fgMuted, bold = true })
  set(0, 'MiniTablineVisible', { fg = p.fg, bg = p.bg4 })
  set(0, 'MiniTablineHidden', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'MiniTablineModifiedCurrent', {
    fg = p.fgMuted,
    bg = p.fg,
    bold = true,
  })
  set(0, 'MiniTablineModifiedVisible', { fg = p.bg4, bg = p.fg })
  set(0, 'MiniTablineModifiedHidden', { fg = p.bg4, bg = p.fgMuted })
  set(0, 'MiniTablineTabpagesection', {
    fg = p.fg,
    bg = p.bg3,
    bold = true,
  })
  set(0, 'MiniHipatternsNote', { fg = p.bg1, bg = p.info, bold = true })
  set(0, 'MiniHipatternsTodo', { fg = p.bg1, bg = p.teal, bold = true })
  set(0, 'MiniHipatternsFixme', { fg = p.bg1, bg = p.error_, bold = true })
  set(0, 'MiniHipatternsHack', { fg = p.bg1, bg = p.purple, bold = true })
  set(0, 'MiniIndentscopePrefix', { nocombine = true })
  set(0, 'MiniTrailspace', { bg = p.error_ })
  set(0, 'MiniJump', { fg = p.bg1, bg = p.purple })
  set(0, 'MiniJump2dSpot', { fg = p.typeParam, bold = true })
  set(0, 'MiniJump2dSpotUnique', { fg = p.teal, bold = true })
  set(
    0,
    'MiniJump2dSpotAhead',
    { fg = p.typeParam, bg = p.bg2, nocombine = true }
  )
  set(0, 'MiniDiffSignAdd', { fg = p.added })
  set(0, 'MiniDiffSignChange', { fg = p.modified })
  set(0, 'MiniDiffSignDelete', { fg = p.deleted })
  set(0, 'MiniCompletionActiveParameter', { underline = true })
  set(0, 'MiniTestFail', { fg = p.error_, bold = true })
  set(0, 'MiniTestPass', { fg = p.teal, bold = true })
  set(0, 'MiniTestEmphasis', { bold = true })
  set(0, 'MiniDepsTitleError', { fg = p.bg1, bg = p.error_ })
  set(0, 'MiniDepsTitleUpdate', { fg = p.bg1, bg = p.teal })
  set(0, 'MiniFilesFile', { fg = p.fg })
  set(0, 'MiniFilesTitleFocused', { fg = p.fg, bold = true })
  set(0, 'MiniAnimateCursor', { reverse = true, nocombine = true })
  set(0, 'MiniIconsGreen', { fg = p.added })
  set(0, 'MiniIconsRed', { fg = p.error_ })
  set(0, 'MiniIconsYellow', { fg = p.warning })
  set(0, 'MiniIconsBlue', { fg = p.func })
  set(0, 'MiniIconsPurple', { fg = p.purple })
  set(0, 'MiniIconsAzure', { fg = p.teal })
  set(0, 'MiniIconsCyan', { fg = p.cyan })
  set(0, 'MiniIconsOrange', { fg = p.warning })
  set(0, 'MiniIconsGrey', { fg = p.fgBright })

  -- DAP UI
  set(0, 'DapUINormalNC', { bg = p.bg3 })
  set(0, 'DapUIStepBackNC', { bg = p.bg3 })
  set(0, 'DapUIStepIntoNC', { bg = p.bg3 })
  set(0, 'DapUIStepOverNC', { bg = p.bg3 })
  set(0, 'DapUIStepOutNC', { bg = p.bg3 })
  set(0, 'DapUIRestartNC', { bg = p.bg3 })
  set(0, 'DapUIPlayPauseNC', { bg = p.bg3 })
  set(0, 'DapUIStopNC', { bg = p.bg3 })
  set(0, 'DapUIUnavailableNC', { bg = p.bg3 })
  set(0, 'DapUIVariable', { fg = p.fg })
  set(0, 'DapUIValue', { fg = p.fg })
  set(0, 'DapUIModifiedValue', { fg = p.teal, bold = true })
  set(0, 'DapUIScope', { fg = p.namespace_ })
  set(0, 'DapUIBreakpointsPath', { fg = p.namespace_ })
  set(0, 'DapUIBreakpointsInfo', { fg = p.namespace_ })
  set(0, 'DapUIBreakpointsCurrentLine', { fg = p.teal, bold = true })
  set(0, 'DapUIBreakpointsDisabledLine', { fg = p.fgMuted })
  set(0, 'DapUIWatchesEmpty', { fg = p.error_ })
  set(0, 'DapUIWatchesError', { fg = p.error_ })
  set(0, 'DapUIWatchesValue', { fg = p.purple })
  set(0, 'DapUIStoppedThread', { fg = p.namespace_ })
  set(0, 'DapUIDecoration', { fg = p.fgMuted })
  set(0, 'DapBreak', { fg = p.error_ })
  set(0, 'DapStop', { fg = p.fgMuted })

  -- Aerial
  set(0, 'AerialGuide', { fg = p.bg5 })

  -- Hop / Leap / Lightspeed
  set(0, 'HopNextKey', { fg = p.teal, bold = true })
  set(0, 'HopNextKey1', { fg = p.namespace_, bold = true })
  set(0, 'HopNextKey2', { fg = p.typeParam })
  set(0, 'HopUnmatched', { fg = p.fgMuted })
  set(0, 'LeapBackdrop', { fg = p.fgMuted })
  set(0, 'LeapLabelPrimary', { fg = p.bg2, bg = p.teal })
  set(0, 'LeapLabelSecondary', { fg = p.bg2, bg = p.typeParam })
  set(0, 'LeapMatch', { fg = p.bg2, bg = p.teal })
  set(0, 'LightspeedGreyWash', { fg = p.fgMuted })
  set(0, 'PounceMatch', { fg = p.fg, bg = p.fgMuted })
  set(0, 'PounceGap', { fg = p.fg, bg = p.bg4 })
  set(0, 'PounceAccept', { fg = p.bg2, bg = p.teal })
  set(0, 'PounceAcceptBest', { fg = p.bg2, bg = p.typeParam })

  -- Sneak
  set(0, 'Sneak', { fg = p.bg1, bg = p.purple })
  set(0, 'SneakScope', { bg = p.bg4 })

  -- Blink / Cmp
  set(0, 'BlinkCmpKindDefault', { fg = p.fg })
  set(0, 'BlinkCmpKindSnippet', { fg = p.fg })
  set(0, 'BlinkCmpLabel', { fg = p.fg })
  set(0, 'BlinkCmpLabelMatch', { fg = p.teal })
  set(0, 'BlinkCmpLabelDeprecated', { fg = p.fgMuted, strikethrough = true })
  set(0, 'BlinkCmpDoc', { fg = p.fg, bg = p.bg2 })
  set(0, 'BlinkCmpDocBorder', { fg = p.bg5, bg = p.bg2 })
  set(0, 'CmpItemKindDefault', { fg = p.fg })
  set(0, 'CmpItemKindSnippet', { fg = p.fg })
  set(0, 'CmpItemAbbr', { fg = p.fg })
  set(0, 'CmpItemAbbrMatch', { fg = p.teal })
  set(0, 'CmpItemAbbrMatchFuzzy', { fg = p.teal })
  set(0, 'CmpItemAbbrDeprecated', { fg = p.fgMuted, strikethrough = true })
  set(0, 'CmpDocumentation', { fg = p.fg, bg = p.bg2 })
  set(0, 'CmpDocumentationBorder', { fg = p.bg5, bg = p.bg2 })

  -- slimline
  set(0, 'Slimline', { fg = p.fg, bg = p.bg0 })
  set(0, 'SlimlineInactive', { fg = p.fgDim, bg = p.bg0 })
  set(0, 'SlimlineModeNormal', { fg = p.teal, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeInsert', { fg = p.typeParam, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeVisual', { fg = p.darkRed, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeReplace', { fg = p.keyword, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeCommand', { fg = p.namespace_, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeOther', { fg = p.namespace_, bg = p.bg4, bold = true })
  set(0, 'SlimlineModeSecondary', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'SlimlineModeNormalSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeInsertSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeVisualSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeReplaceSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeCommandSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeOtherSep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeSecondarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineModeNormalSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineModeInsertSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineModeVisualSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineModeReplaceSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineModeCommandSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineModeOtherSep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineGitPrimary', { fg = p.warning, bg = p.bg4 })
  set(0, 'SlimlineGitPrimarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineGitPrimarySep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineGitSecondary', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'SlimlineGitSecondarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlinePathPrimary', { fg = p.darkRed, bg = p.bg4 })
  set(0, 'SlimlinePathPrimarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlinePathPrimarySep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlinePathSecondary', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'SlimlinePathSecondarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineFiletype_lspPrimary', { fg = p.fg, bg = p.bg4 })
  set(0, 'SlimlineFiletype_lspPrimarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineFiletype_lspPrimarySep2Sec', { fg = p.bg4, bg = p.bg4 })
  set(0, 'SlimlineFiletype_lspSecondary', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'SlimlineFiletype_lspSecondarySep', { fg = p.bg4, bg = p.bg0 })
  set(0, 'SlimlineDiagnosticsError', { fg = p.error_, bg = p.bgRed })
  set(0, 'SlimlineDiagnosticsWarn', { fg = p.warning, bg = p.bgYellow })
  set(0, 'SlimlineDiagnosticsInfo', { fg = p.info, bg = p.bgBlue })
  set(0, 'SlimlineDiagnosticsHint', { fg = p.hint, bg = p.bgGreen })
  set(0, 'SlimlineDiagnosticsSecondary', { fg = p.fgMuted, bg = p.bg4 })
  set(0, 'SlimlineDiagnosticsErrorSep', { fg = p.bgRed, bg = p.bg0 })
  set(0, 'SlimlineDiagnosticsWarnSep', { fg = p.bgYellow, bg = p.bg0 })
  set(0, 'SlimlineDiagnosticsInfoSep', { fg = p.bgBlue, bg = p.bg0 })
  set(0, 'SlimlineDiagnosticsHintSep', { fg = p.bgGreen, bg = p.bg0 })
  set(0, 'SlimlineDiagnosticsSecondarySep', { fg = p.bg4, bg = p.bg0 })

  -- Bufferline / Barbar
  set(0, 'BufferCurrent', { fg = p.fg, bg = p.fgMuted })
  set(0, 'BufferCurrentMod', { fg = p.purple, bg = p.fgMuted })
  set(0, 'BufferCurrentSign', { fg = p.teal, bg = p.fgMuted })
  set(0, 'BufferCurrentIndex', { fg = p.teal, bg = p.fgMuted })
  set(0, 'BufferCurrentTarget', { fg = p.error_, bg = p.fgMuted })
  set(0, 'BufferVisible', { fg = p.fg, bg = p.bg2 })
  set(0, 'BufferVisibleMod', { fg = p.purple, bg = p.bg2 })
  set(0, 'BufferVisibleSign', { fg = p.namespace_, bg = p.bg2 })
  set(0, 'BufferVisibleIndex', { fg = p.namespace_, bg = p.bg2 })
  set(0, 'BufferVisibleTarget', { fg = p.error_, bg = p.bg2 })
  set(0, 'BufferInactive', { fg = p.fgMuted, bg = p.bg2 })
  set(0, 'BufferInactiveMod', { fg = p.bg4, bg = p.bg2 })
  set(0, 'BufferInactiveSign', { fg = p.bg5, bg = p.bg2 })
  set(0, 'BufferInactiveIndex', { fg = p.fgMuted, bg = p.bg2 })
  set(0, 'BufferInactiveTarget', { fg = p.error_, bg = p.bg2 })
  set(0, 'BufferTabpage', { fg = p.bg5, bg = p.bg2 })
  set(0, 'BufferTabpages', { bg = p.bg2 })

  -- Notify
  set(0, 'NotifyERRORTitle', { fg = p.error_ })
  set(0, 'NotifyERRORBorder', { fg = p.bgRed })
  set(0, 'NotifyWARNTitle', { fg = p.warning })
  set(0, 'NotifyWARNBorder', { fg = p.warning })
  set(0, 'NotifyINFOTitle', { fg = p.info })
  set(0, 'NotifyINFOBorder', { fg = p.bgBlue })
  set(0, 'NotifyINFOTitle40', { fg = p.bg2 })
  set(0, 'NotifyINFOBody40', { fg = p.bg2, bg = p.bg2 })
  set(0, 'NotifyINFOIcon40', { fg = p.bg2 })
  set(0, 'NotifyINFOBorder40', { fg = p.bg1 })
  set(0, 'NotifyDEBUGTitle', { fg = p.teal })
  set(0, 'NotifyDEBUGBorder', { fg = p.bgGreen })
  set(0, 'NotifyTRACETitle', { fg = p.fgMuted })
  set(0, 'NotifyTRACEBorder', { fg = p.bg5 })

  -- ============================================================================
  -- Additional
  -- ============================================================================
  set(0, 'Todo', { fg = p.bg2, bg = p.info })
  set(0, 'TodoFgTODO', { fg = p.info })
  set(0, 'TodoFgFIX', { fg = p.error_ })
  set(0, 'TodoFgWARN', { fg = p.warning })
  set(0, 'TodoFgNOTE', { fg = p.teal })
  set(0, 'TodoFgTEST', { fg = p.namespace_ })
  set(0, 'TodoFgPERF', { fg = p.func })
  set(0, 'TodoFgHACK', { fg = p.purple })
  set(0, 'TodoBgTODO', { fg = p.bg2, bg = p.info, bold = true })
  set(0, 'TodoBgFIX', { fg = p.bg2, bg = p.error_, bold = true })
  set(0, 'TodoBgWARN', { fg = p.bg2, bg = p.warning, bold = true })
  set(0, 'TodoBgNOTE', { fg = p.bg2, bg = p.teal, bold = true })
  set(0, 'TodoBgTEST', { fg = p.bg2, bg = p.namespace_, bold = true })
  set(0, 'TodoBgPERF', { fg = p.bg2, bg = p.func, bold = true })
  set(0, 'TodoBgHACK', { fg = p.bg2, bg = p.purple, bold = true })
  set(0, 'TodoSignTODO', { fg = p.info })
  set(0, 'TodoSignFIX', { fg = p.error_ })
  set(0, 'TodoSignWARN', { fg = p.warning })
  set(0, 'TodoSignNOTE', { fg = p.teal })
  set(0, 'TodoSignTEST', { fg = p.namespace_ })
  set(0, 'TodoSignPERF', { fg = p.func })
  set(0, 'TodoSignHACK', { fg = p.purple })

  set(0, 'ModesInsert', { bg = p.typeParam })
  set(0, 'ModesVisual', { bg = p.purple })
  set(0, 'ModesCopy', { bg = p.teal })
  set(0, 'ModesDelete', { bg = p.error_ })

  set(0, 'SnacksImageMath', { fg = p.namespace_ })
  set(0, 'NavicText', { fg = p.fg })
  set(0, 'NavicSeparator', { fg = p.bg5 })
  set(0, 'FernBranchText', { fg = p.namespace_ })
  set(0, 'NoiceHiddenCursor', { nocombine = true, blend = 100 })
  set(0, 'NoiceFormatProgressDone', { fg = p.fg, bg = p.fgMuted })
  set(0, 'RedrawDebugNormal', { reverse = true })
  set(0, 'RedrawDebugClear', { bg = p.fgMuted })
  set(0, 'RedrawDebugComposed', { bg = p.teal })
  set(0, 'RedrawDebugRecompose', { bg = p.error_ })
  set(0, 'CocInlayHint', { fg = p.fgMuted, bg = p.bg4 })

  set(0, 'GlyphPalette0', { fg = p.bg4 })
  set(0, 'GlyphPalette1', { fg = p.error_ })
  set(0, 'GlyphPalette2', { fg = p.added })
  set(0, 'GlyphPalette3', { fg = p.warning })
  set(0, 'GlyphPalette4', { fg = p.func })
  set(0, 'GlyphPalette5', { fg = p.purple })
  set(0, 'GlyphPalette6', { fg = p.teal })
  set(0, 'GlyphPalette7', { fg = p.fg })
  set(0, 'GlyphPalette8', { fg = p.bg5 })
  set(0, 'GlyphPalette9', { fg = p.warning })
  set(0, 'GlyphPalette10', { fg = p.added })
  set(0, 'GlyphPalette11', { fg = p.warning })
  set(0, 'GlyphPalette12', { fg = p.namespace_ })
  set(0, 'GlyphPalette13', { fg = p.purple })
  set(0, 'GlyphPalette14', { fg = p.teal })
  set(0, 'GlyphPalette15', { fg = p.fg })

  set(0, 'typescriptParens', { fg = p.fg })
end

return M
