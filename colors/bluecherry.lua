vim.o.termguicolors = true
vim.g.colors_name = 'blue_cherry'

local p = {
  sumiInk0 = '#0c0c10',
  sumiInk1 = '#101116',
  sumiInk2 = '#161620',
  sumiInk3 = '#1c1c28',
  sumiInk4 = '#2a2a38',
  sumiInk5 = '#303040',
  sumiInk6 = '#c7c7c7',
  waveBlue1 = '#1a1a30',
  waveBlue2 = '#2a2a50',
  winterGreen = '#1a3a25',
  winterYellow = '#3a3920',
  winterRed = '#3a1520',
  winterBlue = '#1a1a30',
  autumnRed = '#ea3355',
  samuraiRed = '#ea3355',
  waveRed = '#ea3355',
  autumnGreen = '#355E3B',
  springGreen = '#0B6E4F',
  roninYellow = '#e8d44d',
  carpYellow = '#e8d44d',
  waveAqua1 = '#4ec9b0',
  dragonBlue = '#6a71f6',
  crystalBlue = '#6a71f6',
  springBlue = '#306fb1',
  oniViolet = '#ba3ec1',
  oldWhite = '#c7c7c7',
  fujiWhite = '#ffffff',
  fujiGray = '#686868',
  katanaGray = '#505060',
  darkBlue = '#040D19',
}

local set = vim.api.nvim_set_hl

-- ============================================================================
-- UI / Editor
-- ============================================================================
set(0, 'Normal', { fg = p.oldWhite, bg = p.darkBlue })
set(0, 'NormalNC', { fg = p.oldWhite, bg = p.darkBlue })
set(0, 'NormalFloat', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'CursorLine', { bg = p.sumiInk2 })
set(0, 'CursorLineNr', { fg = p.waveRed, bold = false })
set(0, 'LineNr', { fg = p.katanaGray })
set(0, 'NonText', { fg = p.sumiInk5 })
set(0, 'EndOfBuffer', { fg = p.sumiInk2 })
set(0, 'SignColumn', { fg = p.oldWhite })
set(0, 'Folded', { fg = p.fujiGray, bg = p.sumiInk3 })
set(0, 'FoldColumn', { fg = p.fujiGray })
set(0, 'ColorColumn', { bg = p.sumiInk3 })
set(0, 'Conceal', { fg = p.sumiInk5 })
set(0, 'MatchParen', { fg = p.oniViolet, bold = true })
set(0, 'Search', { fg = p.sumiInk1, bg = p.waveRed })
set(0, 'IncSearch', { fg = p.sumiInk1, bg = p.sumiInk6 })
set(0, 'Visual', { bg = p.waveBlue2 })
set(0, 'Pmenu', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'PmenuSel', { bg = p.sumiInk4 })
set(0, 'PmenuThumb', { bg = p.fujiGray })
set(0, 'TabLine', { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, 'TabLineSel', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'TabLineFill', { bg = p.sumiInk1 })
set(0, 'VertSplit', { fg = p.sumiInk4 })
set(0, 'StatusLine', { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, 'StatusLineNC', { fg = p.katanaGray, bg = p.sumiInk2 })
set(0, 'WinBar', { fg = p.fujiGray, bg = p.sumiInk2, bold = true })
set(0, 'WinBarNC', { fg = p.fujiGray, bg = p.sumiInk2, bold = true })
set(0, 'FloatBorder', { fg = p.fujiGray })
set(0, 'FloatShadow', { blend = 80 })
set(0, 'FloatShadowThrough', { blend = 100 })
set(0, 'Cursor', { fg = p.sumiInk2, bg = p.oldWhite })
set(0, 'TermCursor', { reverse = true })
set(0, 'Whitespace', { fg = p.sumiInk5 })

-- ============================================================================
-- Syntax (classic vim groups — fallback for non-TS filetypes)
-- ============================================================================
set(0, 'Comment', { fg = p.fujiGray, italic = true })
set(0, 'Keyword', { fg = p.waveRed })
set(0, 'Identifier', { fg = p.oldWhite })
set(0, 'Function', { fg = p.waveAqua1 })
set(0, 'String', { fg = p.springGreen })
set(0, 'Number', { fg = p.oniViolet })
set(0, 'Boolean', { fg = p.waveAqua1 })
set(0, 'Float', { fg = p.oniViolet })
set(0, 'Type', { fg = p.waveAqua1 })
set(0, 'Operator', { fg = p.autumnRed })
set(0, 'Constant', { fg = p.waveAqua1 })
set(0, 'PreProc', { fg = p.springBlue })
set(0, 'Special', { fg = p.dragonBlue })
set(0, 'Statement', { fg = p.waveRed })
set(0, 'Conditional', { fg = p.waveRed })
set(0, 'Repeat', { fg = p.waveRed })
set(0, 'Label', { fg = p.waveAqua1 })
set(0, 'Exception', { fg = p.samuraiRed })
set(0, 'Include', { fg = p.sumiInk6 })
set(0, 'Define', { fg = p.sumiInk6 })
set(0, 'Macro', { fg = p.springBlue })
set(0, 'StorageClass', { fg = p.waveRed })
set(0, 'Structure', { fg = p.waveAqua1 })
set(0, 'Typedef', { fg = p.waveAqua1 })
set(0, 'Title', { fg = p.dragonBlue, bold = true })
set(0, 'Underlined', { underline = true })
set(0, 'Bold', { bold = true })
set(0, 'Italic', { italic = true })
set(0, 'Directory', { fg = p.dragonBlue })

-- ============================================================================
-- Diagnostic
-- ============================================================================
set(0, 'DiagnosticError', { fg = p.samuraiRed })
set(0, 'DiagnosticWarn', { fg = p.roninYellow })
set(0, 'DiagnosticInfo', { fg = p.dragonBlue })
set(0, 'DiagnosticHint', { fg = p.waveAqua1 })
set(0, 'DiagnosticOk', { fg = p.springGreen })
set(0, 'DiagnosticUnderlineError', { undercurl = true, sp = p.samuraiRed })
set(0, 'DiagnosticUnderlineWarn', { undercurl = true, sp = p.roninYellow })
set(0, 'DiagnosticUnderlineInfo', { undercurl = true, sp = p.dragonBlue })
set(0, 'DiagnosticUnderlineHint', { undercurl = true, sp = p.waveAqua1 })
set(0, 'DiagnosticUnderlineOk', { undercurl = true, sp = p.springGreen })
set(0, 'DiagnosticVirtualTextError', { fg = p.samuraiRed, bg = p.winterRed })
set(0, 'DiagnosticVirtualTextWarn', { fg = p.roninYellow, bg = p.winterYellow })
set(0, 'DiagnosticVirtualTextInfo', { fg = p.dragonBlue, bg = p.waveBlue1 })
set(0, 'DiagnosticVirtualTextHint', { fg = p.waveAqua1, bg = p.winterGreen })
set(0, 'DiagnosticVirtualTextOk', { fg = p.springGreen, bg = p.winterGreen })
set(0, 'DiagnosticDeprecated', { strikethrough = true })

-- ============================================================================
-- Git / Diff
-- ============================================================================
set(0, 'DiffAdd', { bg = p.winterGreen })
set(0, 'DiffDelete', { bg = p.winterRed })
set(0, 'DiffChange', { bg = p.winterYellow })
set(0, 'DiffText', { bg = p.waveBlue2 })
set(0, 'GitSignsAdd', { fg = p.springGreen })
set(0, 'GitSignsChange', { fg = p.waveAqua1 })
set(0, 'GitSignsDelete', { fg = p.samuraiRed })
set(0, 'GitSignsAddNr', { fg = p.springGreen })
set(0, 'GitSignsChangeNr', { fg = p.waveAqua1 })
set(0, 'GitSignsDeleteNr', { fg = p.samuraiRed })
set(0, 'GitSignsStagedAdd', { fg = p.springGreen })
set(0, 'GitSignsStagedChange', { fg = p.waveAqua1 })
set(0, 'GitSignsStagedDelete', { fg = p.samuraiRed })

-- ============================================================================
-- LSP
-- ============================================================================
set(0, 'LspReferenceText', { bg = p.sumiInk4 })
set(0, 'LspReferenceRead', { bg = p.sumiInk4 })
set(0, 'LspReferenceWrite', { bg = p.sumiInk4 })
set(0, 'LspCodeLens', { fg = p.fujiGray })
set(0, 'LspCodeLensSeparator', { fg = p.fujiGray })
set(0, 'LspInlayHint', { fg = p.fujiGray, bg = p.sumiInk3 })
set(0, 'LspSignatureActiveParameter', { fg = p.sumiInk6, bold = true })
set(0, 'LspFloatWinNormal', { bg = p.sumiInk1 })
set(0, 'LspFloatWinBorder', { fg = p.fujiGray })
set(0, 'LspSagaHoverBorder', { fg = p.fujiGray })
set(0, 'LspSagaSignatureHelpBorder', { fg = p.samuraiRed })
set(0, 'LspSagaCodeActionBorder', { fg = p.fujiGray })
set(0, 'LspSagaRenameBorder', { fg = p.fujiGray })
set(0, 'LspSagaDefPreviewBorder', { fg = p.fujiGray })
set(0, 'LspSagaFinderSelection', { fg = p.sumiInk4 })
set(0, 'LspTroubleNormal', { fg = p.fujiGray, bg = p.sumiInk1 })
set(0, 'LspTroubleText', { fg = p.oldWhite })
set(0, 'LspTroubleCount', { fg = p.oniViolet, bg = p.fujiGray })

-- ============================================================================
-- Treesitter & Semantic Tokens
-- ============================================================================

-- ── Variables ────────────────────────────────────────────────────────────────
set(0, '@variable', { fg = p.oldWhite })
set(0, '@variable.builtin', { fg = p.samuraiRed }) -- self, this, etc.
set(0, '@variable.member', { fg = p.dragonBlue }) -- struct fields
set(0, '@variable.parameter', { fg = p.springBlue }) -- fn parameters

-- ── Constants ────────────────────────────────────────────────────────────────
set(0, '@constant', { fg = p.waveAqua1 })
set(0, '@constant.builtin', { fg = p.waveAqua1, bold = true }) -- nil, true, false
set(0, '@constant.macro', { fg = p.sumiInk6 }) -- C/Rust macro consts

-- ── Namespaces / modules ──────────────────────────────────────────────────────
set(0, '@module', { fg = p.springBlue })
set(0, '@module.builtin', { fg = p.springBlue, bold = true })
set(0, '@namespace', { fg = p.springBlue })

-- ── Functions ────────────────────────────────────────────────────────────────
set(0, '@function', { fg = p.waveAqua1 })
set(0, '@function.builtin', { fg = p.waveAqua1 }) -- len(), print(), etc.
set(0, '@function.call', { fg = p.waveAqua1 })
set(0, '@function.macro', { fg = p.sumiInk6 }) -- macro_name! calls
set(0, '@function.method', { fg = p.waveAqua1 })
set(0, '@function.method.call', { fg = p.waveAqua1 })
set(0, '@constructor', { fg = p.waveAqua1 }) -- Type::new(), SomeStruct{}

-- ── Parameters ───────────────────────────────────────────────────────────────
set(0, '@parameter', { fg = p.springBlue })

-- ── Keywords ─────────────────────────────────────────────────────────────────
set(0, '@keyword', { fg = p.waveRed })
set(0, '@keyword.function', { fg = p.waveRed }) -- fn, func, def
set(0, '@keyword.operator', { fg = p.autumnRed }) -- and, or, not, instanceof
set(0, '@keyword.return', { fg = p.samuraiRed })
set(0, '@keyword.import', { fg = p.sumiInk6 }) -- use, import
set(0, '@keyword.modifier', { fg = p.waveRed }) -- pub, static, async
set(0, '@keyword.repeat', { fg = p.waveRed }) -- for, while, loop
set(0, '@keyword.conditional', { fg = p.waveRed })
set(0, '@keyword.conditional.ternary', { fg = p.waveRed })
set(0, '@keyword.exception', { fg = p.samuraiRed }) -- throw, catch, panic
set(0, '@keyword.type', { fg = p.waveAqua1 }) -- type, struct, enum

-- ── Types ────────────────────────────────────────────────────────────────────
set(0, '@type', { fg = p.waveAqua1 })
set(0, '@type.builtin', { fg = p.springBlue }) -- u32, str, int, bool
set(0, '@type.definition', { fg = p.waveAqua1, bold = true }) -- the name in `type Foo = …`
set(0, '@type.qualifier', { fg = p.waveRed }) -- const, mut, volatile

-- ── Properties / fields ──────────────────────────────────────────────────────
set(0, '@property', { fg = p.dragonBlue })
set(0, '@field', { fg = p.dragonBlue })
-- set(0, '@field.rust', { fg = p.oldWhite })

-- ── Strings ──────────────────────────────────────────────────────────────────
set(0, '@string', { fg = p.springGreen })
set(0, '@string.regex', { fg = p.waveAqua1 })
set(0, '@string.escape', { fg = p.sumiInk6, bold = true }) -- \n, \t, \u{…}
set(0, '@string.special', { fg = p.waveAqua1 })
set(0, '@string.special.url', { fg = p.waveAqua1, italic = true, underline = true })
set(0, '@string.special.path', { fg = p.waveAqua1, italic = true })

-- ── Characters ───────────────────────────────────────────────────────────────
set(0, '@character', { fg = p.springGreen })
set(0, '@character.special', { fg = p.sumiInk6 })

-- ── Numbers ──────────────────────────────────────────────────────────────────
set(0, '@number', { fg = p.fujiWhite })
set(0, '@number.float', { fg = p.fujiWhite })

-- ── Operators ────────────────────────────────────────────────────────────────
set(0, '@operator', { fg = p.autumnRed })

-- ── Punctuation ──────────────────────────────────────────────────────────────
-- Fine-grained: delimiters (. , ;), brackets (()[]{}) and specials
set(0, '@punctuation.delimiter', { fg = p.oldWhite }) -- . , ; :
set(0, '@punctuation.bracket', { fg = p.fujiGray }) -- ( ) [ ] { }  — slightly muted
set(0, '@punctuation.special', { fg = p.springBlue }) -- interpolation delimiters, *spread*

-- ── Attributes / annotations ─────────────────────────────────────────────────
-- #[…] in Rust, @annotation in Java/TS, etc.
-- The "outer" attribute wrapper
set(0, '@attribute', { fg = p.springBlue }) -- the whole #[…] in simple parsers
-- Finer tokens where the grammar exposes them:
set(0, '@attribute.builtin', { fg = p.sumiInk6 }) -- #, @, [[
set(0, '@punctuation.special.attribute', { fg = p.fujiGray }) -- [ ] surrounding the attr (if exposed)

-- Rust-specific attribute anatomy
--   #[derive(Resource, Component)]
--   ^^  ──── sumiInk6 (keyword/macro marker)
--      ^^^^^^  ──── waveAqua1 (the derive "function" is a proc-macro)
--             ^^^^^^^^^^^^^^^^^^^  ──── waveAqua1 / springBlue (types inside)
set(0, '@lsp.type.attribute', { fg = p.sumiInk6 }) -- LSP semantic: attribute names
set(0, '@lsp.type.derive', { fg = p.sumiInk6 }) -- LSP semantic: derive target name
set(0, '@lsp.type.attributeBracket', { fg = p.waveAqua1 }) -- LSP: [ ] of the attribute

-- ── Comments ─────────────────────────────────────────────────────────────────
set(0, '@comment', { fg = p.fujiGray, italic = true })
set(0, '@comment.note', { fg = p.sumiInk2, bg = p.dragonBlue })
set(0, '@comment.todo', { fg = p.sumiInk2, bg = p.waveAqua1 })
set(0, '@comment.warning', { fg = p.sumiInk2, bg = p.roninYellow })
set(0, '@comment.error', { fg = p.sumiInk2, bg = p.samuraiRed })
set(0, '@comment.documentation', { fg = p.fujiGray, italic = true }) -- ///, /** */

-- ── Markup (markdown / rst / etc.) ───────────────────────────────────────────
set(0, '@markup', { fg = p.oldWhite })
set(0, '@markup.heading', { fg = p.dragonBlue, bold = true })
set(0, '@markup.heading.1', { fg = p.dragonBlue, bold = true })
set(0, '@markup.heading.2', { fg = p.dragonBlue, bold = true })
set(0, '@markup.heading.3', { fg = p.springBlue, bold = true })
set(0, '@markup.heading.4', { fg = p.waveAqua1, bold = true })
set(0, '@markup.heading.5', { fg = p.waveAqua1 })
set(0, '@markup.heading.6', { fg = p.fujiGray })
set(0, '@markup.strong', { fg = p.sumiInk6, bold = true })
set(0, '@markup.italic', { italic = true })
set(0, '@markup.strikethrough', { fg = p.oldWhite, strikethrough = true })
set(0, '@markup.link', { fg = p.oniViolet, bold = true })
set(0, '@markup.link.url', { fg = p.waveAqua1, underline = true })
set(0, '@markup.link.label', { fg = p.springBlue })
set(0, '@markup.list', { fg = p.springBlue })
set(0, '@markup.list.checked', { fg = p.springGreen })
set(0, '@markup.list.unchecked', { fg = p.waveAqua1 })
set(0, '@markup.raw', { fg = p.springBlue, italic = true })
set(0, '@markup.raw.block', { fg = p.sumiInk6 })
set(0, '@markup.quote', { fg = p.fujiGray, italic = true })
set(0, '@markup.math', { fg = p.dragonBlue })

-- ── Tags (HTML/JSX/TSX/XML) ───────────────────────────────────────────────────
set(0, '@tag', { fg = p.waveRed }) -- tag name: <div>
set(0, '@tag.builtin', { fg = p.waveRed }) -- built-in tags
set(0, '@tag.attribute', { fg = p.dragonBlue, italic = true }) -- attr names: class=
set(0, '@tag.delimiter', { fg = p.fujiGray }) -- < > / (tag punctuation)

-- ── Legacy @text.* (nvim-treesitter < 0.9 compat) ────────────────────────────
-- set(0, '@text', { fg = p.oldWhite })
-- set(0, '@text.note', { fg = p.sumiInk2, bg = p.dragonBlue })
-- set(0, '@text.warning', { fg = p.sumiInk2, bg = p.roninYellow })
-- set(0, '@text.danger', { fg = p.sumiInk2, bg = p.samuraiRed })
-- set(0, '@text.todo', { fg = p.sumiInk2, bg = p.waveAqua1 })
-- set(0, '@text.todo.checked', { fg = p.springGreen })
-- set(0, '@text.todo.unchecked', { fg = p.waveAqua1 })
-- set(0, '@text.reference', { fg = p.oniViolet, bold = true })
-- set(0, '@text.literal', { fg = p.springBlue, italic = true })
-- set(0, '@text.math', { fg = p.dragonBlue })
-- set(0, '@punctuation.special.rust', { fg = p.sumiInk6 }) -- # sign
-- set(0, '@punctuation.bracket.rust', { fg = p.fujiGray }) -- [ ] around attr body
-- set(0, '@function.macro.rust', { fg = p.waveAqua1 }) -- derive, cfg, allow…
-- set(0, '@type.rust', { fg = p.waveAqua1 }) -- type names inside attrs

-- Lua: constructors are plain tables
set(0, '@constructor.lua', { fg = p.oldWhite })

-- JSON: keys as properties (distinct from string values)
set(0, '@label.json', { fg = p.dragonBlue })
set(0, '@property.json', { fg = p.dragonBlue })

-- TypeScript/JavaScript: JSX attribute names distinct from regular props
set(0, '@tag.attribute.tsx', { fg = p.dragonBlue, italic = true })
set(0, '@tag.attribute.jsx', { fg = p.dragonBlue, italic = true })

-- LSP semantic tokens
set(0, '@lsp.type.interface', { fg = p.sumiInk6 })
set(0, '@lsp.type.enum', { fg = p.waveAqua1 })
set(0, '@lsp.type.enumMember', { fg = p.waveAqua1 })
set(0, '@lsp.type.struct', { fg = p.fujiWhite })
set(0, '@lsp.type.typeParameter', { fg = p.springBlue })
set(0, '@lsp.type.namespace', { fg = p.springBlue })
set(0, '@lsp.type.macro', { fg = p.sumiInk6 })
set(0, '@lsp.type.variable', { link = '@variable' })
set(0, '@lsp.type.parameter', { link = '@variable.parameter' })
set(0, '@lsp.type.property', { link = '@property' })
set(0, '@lsp.type.function', { link = '@function' })
set(0, '@lsp.type.method', { link = '@function.method' })
set(0, '@lsp.type.keyword', { link = '@keyword' })
set(0, '@lsp.type.string', { link = '@string' })
set(0, '@lsp.type.number', { link = '@number' })
set(0, '@lsp.type.comment', { link = '@comment' })
set(0, '@lsp.mod.deprecated', { strikethrough = true })
set(0, '@lsp.mod.readonly', { fg = p.waveAqua1 })
set(0, '@lsp.mod.static', { fg = p.springGreen, bold = true })

-- ============================================================================
-- Plugins (Treesitter, Neogit, Neotest, etc.)
-- ============================================================================

-- Neogit
set(0, 'NeogitBranch', { fg = p.oniViolet })
set(0, 'NeogitRemote', { fg = p.waveAqua1 })
set(0, 'NeogitHunkHeader', { fg = p.dragonBlue, bg = p.sumiInk5 })
set(0, 'NeogitHunkHeaderHighlight', { fg = p.dragonBlue, bg = p.sumiInk4 })
set(0, 'NeogitDiffAdd', { fg = p.springGreen })
set(0, 'NeogitDiffAddHighlight', { bg = p.winterGreen })
set(0, 'NeogitDiffDelete', { fg = p.samuraiRed })
set(0, 'NeogitDiffDeleteHighlight', { bg = p.winterRed })
set(0, 'NeogitDiffContextHighlight', { bg = p.sumiInk3 })
set(0, 'NeogitNotificationError', { fg = p.samuraiRed })
set(0, 'NeogitNotificationWarning', { fg = p.roninYellow })
set(0, 'NeogitNotificationInfo', { fg = p.dragonBlue })

-- Neotest
set(0, 'NeotestPassed', { fg = p.springGreen })
set(0, 'NeotestFailed', { fg = p.samuraiRed })
set(0, 'NeotestSkipped', { fg = p.oniViolet })
set(0, 'NeotestRunning', { fg = p.waveAqua1 })
set(0, 'NeotestFocused', { underline = true })
set(0, 'NeotestMarked', { fg = p.oldWhite, bold = true })
set(0, 'NeotestNamespace', { fg = p.springBlue })
set(0, 'NeotestDir', { fg = p.springBlue })
set(0, 'NeotestFile', { fg = p.dragonBlue })
set(0, 'NeotestAdapterName', { fg = p.sumiInk6, bold = true })

-- Neo-tree
set(0, 'NeoTreeNormal', { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, 'NeoTreeTitleBar', { fg = p.sumiInk1, bg = p.fujiGray })
set(0, 'NeoTreeFloatTitle', { fg = p.oldWhite })
set(0, 'NeoTreeFileName', { fg = p.oldWhite })
set(0, 'NeoTreeFileNameOpened', { fg = p.oldWhite })
set(0, 'NeoTreeDirectoryName', { fg = p.dragonBlue })
set(0, 'NeoTreeDirectoryIcon', { fg = p.dragonBlue })
set(0, 'NeoTreeIndentMarker', { fg = p.sumiInk5 })
set(0, 'NeoTreeRootName', { fg = p.waveAqua1, bold = true })
set(0, 'NeoTreeFileStats', { fg = p.fujiGray })
set(0, 'NeoTreeFileStatsHeader', { fg = p.waveAqua1, bold = true })
set(0, 'NeoTreeDotfile', { fg = p.springBlue })
set(0, 'NeoTreeSymbolicLinkTarget', { fg = p.sumiInk6 })
set(0, 'NeoTreeMessage', { fg = p.fujiGray, italic = true })
set(0, 'NeoTreeFadeText1', { fg = p.fujiGray })
set(0, 'NeoTreeFadeText2', { fg = p.sumiInk5 })
set(0, 'NeoTreeGitAdded', { fg = p.springGreen })
set(0, 'NeoTreeGitModified', { fg = p.waveAqua1 })
set(0, 'NeoTreeGitDeleted', { fg = p.samuraiRed })
set(0, 'NeoTreeGitUntracked', { fg = p.oniViolet })
set(0, 'NeoTreeGitIgnored', { fg = p.fujiGray })
set(0, 'NeoTreeGitConflict', { fg = p.roninYellow, italic = true })
set(0, 'NeoTreeTabActive', { bold = true })
set(0, 'NeoTreeTabInactive', { fg = p.fujiGray, bg = p.sumiInk2 })
set(0, 'NeoTreeTabSeparatorActive', { fg = p.sumiInk1 })
set(0, 'NeoTreeTabSeparatorInactive', { fg = p.sumiInk1, bg = p.sumiInk2 })
set(0, 'NeoTreeModified', { fg = p.carpYellow })

-- NvimTree
set(0, 'NvimTreeNormal', { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, 'NvimTreeFolderName', { fg = p.dragonBlue })
set(0, 'NvimTreeFolderIcon', { fg = p.dragonBlue })
set(0, 'NvimTreeOpenedFolderName', { fg = p.dragonBlue })
set(0, 'NvimTreeOpenedFile', { fg = p.sumiInk6 })
set(0, 'NvimTreeEmptyFolderName', { fg = p.fujiGray })
set(0, 'NvimTreeIndentMarker', { fg = p.sumiInk5 })
set(0, 'NvimTreeRootFolder', { fg = p.waveAqua1, bold = true })
set(0, 'NvimTreeSymlink', { fg = p.sumiInk6 })
set(0, 'NvimTreeSpecialFile', { fg = p.springBlue })
set(0, 'NvimTreeImageFile', { fg = p.oldWhite })
set(0, 'NvimTreeGitNew', { fg = p.springGreen })
set(0, 'NvimTreeGitDirty', { fg = p.waveAqua1 })
set(0, 'NvimTreeGitDeleted', { fg = p.samuraiRed })
set(0, 'NvimTreeGitMerge', { fg = p.waveAqua1 })

-- Telescope
set(0, 'TelescopeBorder', { fg = p.sumiInk5 })
set(0, 'TelescopeSelectionCaret', { fg = p.waveAqua1 })
set(0, 'TelescopeSelection', { fg = p.oldWhite, bg = p.sumiInk4 })

-- Dashboard / Alpha
set(0, 'AlphaHeader', { fg = p.dragonBlue })
set(0, 'AlphaFooter', { fg = p.dragonBlue })
set(0, 'AlphaButtons', { fg = p.springBlue })
set(0, 'AlphaShortcut', { fg = p.waveAqua1 })
set(0, 'AlphaHeaderLabel', { fg = p.waveAqua1 })
set(0, 'DashboardFooter', { fg = p.waveAqua1, italic = true })

-- Mini
set(0, 'MiniStarterQuery', { fg = p.springGreen })
set(0, 'MiniStarterItemPrefix', { fg = p.sumiInk6 })
set(0, 'MiniStarterItemBullet', { fg = p.fujiGray })
set(0, 'MiniStarterSection', { fg = p.samuraiRed })
set(0, 'MiniStarterFooter', { fg = p.waveAqua1, italic = true })
set(0, 'MiniStarterCurrent', { nocombine = true })
set(0, 'MiniStatuslineModeNormal', { fg = p.sumiInk1, bg = p.springBlue, bold = true })
set(0, 'MiniStatuslineModeInsert', { fg = p.sumiInk1, bg = p.springGreen, bold = true })
set(0, 'MiniStatuslineModeVisual', { fg = p.sumiInk1, bg = p.oniViolet, bold = true })
set(0, 'MiniStatuslineModeReplace', { fg = p.sumiInk1, bg = p.samuraiRed, bold = true })
set(0, 'MiniStatuslineModeCommand', { fg = p.sumiInk1, bg = p.waveAqua1, bold = true })
set(0, 'MiniStatuslineModeOther', { fg = p.sumiInk1, bg = p.dragonBlue, bold = true })
set(0, 'MiniStatuslineDevinfo', { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, 'MiniStatuslineFileinfo', { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, 'MiniTablineCurrent', { fg = p.oldWhite, bg = p.fujiGray, bold = true })
set(0, 'MiniTablineVisible', { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, 'MiniTablineHidden', { fg = p.fujiGray, bg = p.sumiInk3 })
set(0, 'MiniTablineModifiedCurrent', { fg = p.fujiGray, bg = p.oldWhite, bold = true })
set(0, 'MiniTablineModifiedVisible', { fg = p.sumiInk3, bg = p.oldWhite })
set(0, 'MiniTablineModifiedHidden', { fg = p.sumiInk3, bg = p.fujiGray })
set(0, 'MiniTablineTabpagesection', { fg = p.oldWhite, bg = p.sumiInk2, bold = true })
set(0, 'MiniHipatternsNote', { fg = p.sumiInk1, bg = p.dragonBlue, bold = true })
set(0, 'MiniHipatternsTodo', { fg = p.sumiInk1, bg = p.waveAqua1, bold = true })
set(0, 'MiniHipatternsFixme', { fg = p.sumiInk1, bg = p.samuraiRed, bold = true })
set(0, 'MiniHipatternsHack', { fg = p.sumiInk1, bg = p.oniViolet, bold = true })
set(0, 'MiniIndentscopePrefix', { nocombine = true })
set(0, 'MiniTrailspace', { bg = p.samuraiRed })
set(0, 'MiniJump', { fg = p.sumiInk1, bg = p.oniViolet })
set(0, 'MiniJump2dSpot', { fg = p.springBlue, bold = true })
set(0, 'MiniJump2dSpotUnique', { fg = p.waveAqua1, bold = true })
set(0, 'MiniJump2dSpotAhead', { fg = p.springBlue, bg = p.sumiInk1, nocombine = true })
set(0, 'MiniDiffSignAdd', { fg = p.springGreen })
set(0, 'MiniDiffSignChange', { fg = p.waveAqua1 })
set(0, 'MiniDiffSignDelete', { fg = p.samuraiRed })
set(0, 'MiniCompletionActiveParameter', { underline = true })
set(0, 'MiniTestFail', { fg = p.samuraiRed, bold = true })
set(0, 'MiniTestPass', { fg = p.springGreen, bold = true })
set(0, 'MiniTestEmphasis', { bold = true })
set(0, 'MiniDepsTitleError', { fg = p.sumiInk1, bg = p.samuraiRed })
set(0, 'MiniDepsTitleUpdate', { fg = p.sumiInk1, bg = p.springGreen })
set(0, 'MiniFilesFile', { fg = p.oldWhite })
set(0, 'MiniFilesTitleFocused', { fg = p.oldWhite, bold = true })
set(0, 'MiniAnimateCursor', { reverse = true, nocombine = true })
set(0, 'MiniIconsGreen', { fg = p.springGreen })
set(0, 'MiniIconsRed', { fg = p.samuraiRed })
set(0, 'MiniIconsYellow', { fg = p.sumiInk6 })
set(0, 'MiniIconsBlue', { fg = p.dragonBlue })
set(0, 'MiniIconsPurple', { fg = p.oniViolet })
set(0, 'MiniIconsAzure', { fg = p.dragonBlue })
set(0, 'MiniIconsCyan', { fg = p.springBlue })
set(0, 'MiniIconsOrange', { fg = p.waveAqua1 })
set(0, 'MiniIconsGrey', { fg = p.fujiWhite })

-- DAP UI
set(0, 'DapUINormalNC', { bg = p.sumiInk2 })
set(0, 'DapUIStepBackNC', { bg = p.sumiInk2 })
set(0, 'DapUIStepIntoNC', { bg = p.sumiInk2 })
set(0, 'DapUIStepOverNC', { bg = p.sumiInk2 })
set(0, 'DapUIStepOutNC', { bg = p.sumiInk2 })
set(0, 'DapUIRestartNC', { bg = p.sumiInk2 })
set(0, 'DapUIPlayPauseNC', { bg = p.sumiInk2 })
set(0, 'DapUIStopNC', { bg = p.sumiInk2 })
set(0, 'DapUIUnavailableNC', { bg = p.sumiInk2 })
set(0, 'DapUIVariable', { fg = p.oldWhite })
set(0, 'DapUIValue', { fg = p.oldWhite })
set(0, 'DapUIModifiedValue', { fg = p.oldWhite, bold = true })
set(0, 'DapUIScope', { fg = p.springBlue })
set(0, 'DapUIBreakpointsPath', { fg = p.springBlue })
set(0, 'DapUIBreakpointsInfo', { fg = p.dragonBlue })
set(0, 'DapUIBreakpointsCurrentLine', { fg = p.waveAqua1, bold = true })
set(0, 'DapUIBreakpointsDisabledLine', { fg = p.fujiGray })
set(0, 'DapUIWatchesEmpty', { fg = p.samuraiRed })
set(0, 'DapUIWatchesError', { fg = p.samuraiRed })
set(0, 'DapUIWatchesValue', { fg = p.oniViolet })
set(0, 'DapUIStoppedThread', { fg = p.springBlue })
set(0, 'DapUIDecoration', { fg = p.fujiGray })
set(0, 'DapBreak', { fg = p.samuraiRed })
set(0, 'DapStop', { fg = p.sumiInk6 })

-- Aerial
set(0, 'AerialGuide', { fg = p.sumiInk5 })

-- Hop / Leap / Lightspeed
set(0, 'HopNextKey', { fg = p.springBlue, bold = true })
set(0, 'HopNextKey1', { fg = p.dragonBlue, bold = true })
set(0, 'HopNextKey2', { fg = p.springBlue })
set(0, 'HopUnmatched', { fg = p.fujiGray })
set(0, 'LeapBackdrop', { fg = p.fujiGray })
set(0, 'LeapLabelPrimary', { fg = p.sumiInk2, bg = p.sumiInk6 })
set(0, 'LeapLabelSecondary', { fg = p.sumiInk2, bg = p.springBlue })
set(0, 'LeapMatch', { fg = p.sumiInk2, bg = p.sumiInk6 })
set(0, 'LightspeedGreyWash', { fg = p.fujiGray })
set(0, 'PounceMatch', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'PounceGap', { fg = p.oldWhite, bg = p.sumiInk4 })
set(0, 'PounceAccept', { fg = p.sumiInk2, bg = p.waveAqua1 })
set(0, 'PounceAcceptBest', { fg = p.sumiInk2, bg = p.springBlue })

-- Sneak
set(0, 'Sneak', { fg = p.sumiInk1, bg = p.oniViolet })
set(0, 'SneakScope', { bg = p.sumiInk4 })

-- Blink / Cmp
set(0, 'BlinkCmpKindDefault', { fg = p.oldWhite })
set(0, 'BlinkCmpKindSnippet', { fg = p.oldWhite })
set(0, 'BlinkCmpLabel', { fg = p.oldWhite })
set(0, 'BlinkCmpLabelMatch', { fg = p.dragonBlue })
set(0, 'BlinkCmpLabelDeprecated', { fg = p.fujiGray, strikethrough = true })
set(0, 'BlinkCmpDoc', { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, 'BlinkCmpDocBorder', { fg = p.sumiInk4, bg = p.sumiInk1 })
set(0, 'CmpItemKindDefault', { fg = p.oldWhite })
set(0, 'CmpItemKindSnippet', { fg = p.oldWhite })
set(0, 'CmpItemAbbr', { fg = p.oldWhite })
set(0, 'CmpItemAbbrMatch', { fg = p.dragonBlue })
set(0, 'CmpItemAbbrMatchFuzzy', { fg = p.dragonBlue })
set(0, 'CmpItemAbbrDeprecated', { fg = p.fujiGray, strikethrough = true })
set(0, 'CmpDocumentation', { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, 'CmpDocumentationBorder', { fg = p.sumiInk4, bg = p.sumiInk1 })

-- Slimline / Statusline
set(0, 'Slimline', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'SlimlineInactive', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'SlimlineModeNormal', { fg = p.sumiInk2, bg = p.waveAqua1 })
set(0, 'SlimlineModeInsert', { fg = p.sumiInk2, bg = p.dragonBlue })
set(0, 'SlimlineModeVisual', { fg = p.sumiInk2, bg = p.oniViolet })
set(0, 'SlimlineModeReplace', { fg = p.sumiInk2, bg = p.oniViolet })
set(0, 'SlimlineModeCommand', { fg = p.sumiInk2, bg = p.springGreen })
set(0, 'SlimlineModeOther', { fg = p.sumiInk2, bg = p.dragonBlue })
set(0, 'SlimlineModeSecondary', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'SlimlineModeNormalSep', { fg = p.waveAqua1, bg = p.sumiInk2 })
set(0, 'SlimlineModeInsertSep', { fg = p.dragonBlue, bg = p.sumiInk2 })
set(0, 'SlimlineModeVisualSep', { fg = p.oniViolet, bg = p.sumiInk2 })
set(0, 'SlimlineModeReplaceSep', { fg = p.oniViolet, bg = p.sumiInk2 })
set(0, 'SlimlineModeCommandSep', { fg = p.springGreen, bg = p.sumiInk2 })
set(0, 'SlimlineModeOtherSep', { fg = p.dragonBlue, bg = p.sumiInk2 })
set(0, 'SlimlineModeSecondarySep', { fg = p.fujiGray, bg = p.sumiInk2 })
set(0, 'SlimlineModeNormalSep2Sec', { fg = p.waveAqua1, bg = p.fujiGray })
set(0, 'SlimlineModeInsertSep2Sec', { fg = p.dragonBlue, bg = p.fujiGray })
set(0, 'SlimlineModeVisualSep2Sec', { fg = p.oniViolet, bg = p.fujiGray })
set(0, 'SlimlineModeReplaceSep2Sec', { fg = p.oniViolet, bg = p.fujiGray })
set(0, 'SlimlineModeCommandSep2Sec', { fg = p.springGreen, bg = p.fujiGray })
set(0, 'SlimlineModeOtherSep2Sec', { fg = p.dragonBlue, bg = p.fujiGray })
set(0, 'SlimlineGitPrimary', { fg = p.sumiInk2, bg = p.oldWhite })
set(0, 'SlimlineGitPrimarySep', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'SlimlineGitPrimarySep2Sec', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'SlimlineGitSecondary', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'SlimlineGitSecondarySep', { fg = p.fujiGray, bg = p.sumiInk2 })
set(0, 'SlimlinePathPrimary', { fg = p.sumiInk2, bg = p.oldWhite })
set(0, 'SlimlinePathPrimarySep', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'SlimlinePathPrimarySep2Sec', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'SlimlinePathSecondary', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'SlimlinePathSecondarySep', { fg = p.fujiGray, bg = p.sumiInk2 })
set(0, 'SlimlineFiletype_lspPrimary', { fg = p.sumiInk2, bg = p.oldWhite })
set(0, 'SlimlineFiletype_lspPrimarySep', { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, 'SlimlineFiletype_lspPrimarySep2Sec', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'SlimlineFiletype_lspSecondary', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'SlimlineFiletype_lspSecondarySep', { fg = p.fujiGray, bg = p.sumiInk2 })
set(0, 'SlimlineDiagnosticsError', { fg = p.sumiInk2, bg = p.samuraiRed })
set(0, 'SlimlineDiagnosticsWarn', { fg = p.sumiInk2, bg = p.oniViolet })
set(0, 'SlimlineDiagnosticsInfo', { fg = p.sumiInk2, bg = p.dragonBlue })
set(0, 'SlimlineDiagnosticsHint', { fg = p.sumiInk2, bg = p.waveAqua1 })
set(0, 'SlimlineDiagnosticsSecondary', { fg = p.sumiInk2, bg = p.fujiGray })
set(0, 'SlimlineDiagnosticsErrorSep', { fg = p.samuraiRed, bg = p.sumiInk2 })
set(0, 'SlimlineDiagnosticsWarnSep', { fg = p.oniViolet, bg = p.sumiInk2 })
set(0, 'SlimlineDiagnosticsInfoSep', { fg = p.dragonBlue, bg = p.sumiInk2 })
set(0, 'SlimlineDiagnosticsHintSep', { fg = p.waveAqua1, bg = p.sumiInk2 })
set(0, 'SlimlineDiagnosticsSecondarySep', { fg = p.fujiGray, bg = p.sumiInk2 })

-- Bufferline / Tabline
set(0, 'BufferCurrent', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'BufferCurrentMod', { fg = p.oniViolet, bg = p.fujiGray })
set(0, 'BufferCurrentSign', { fg = p.dragonBlue, bg = p.fujiGray })
set(0, 'BufferCurrentIndex', { fg = p.dragonBlue, bg = p.fujiGray })
set(0, 'BufferCurrentTarget', { fg = p.samuraiRed, bg = p.fujiGray })
set(0, 'BufferVisible', { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, 'BufferVisibleMod', { fg = p.oniViolet, bg = p.sumiInk1 })
set(0, 'BufferVisibleSign', { fg = p.dragonBlue, bg = p.sumiInk1 })
set(0, 'BufferVisibleIndex', { fg = p.dragonBlue, bg = p.sumiInk1 })
set(0, 'BufferVisibleTarget', { fg = p.samuraiRed, bg = p.sumiInk1 })
set(0, 'BufferInactive', { fg = p.fujiGray, bg = p.sumiInk1 })
set(0, 'BufferInactiveMod', { fg = p.sumiInk3, bg = p.sumiInk1 })
set(0, 'BufferInactiveSign', { fg = p.sumiInk5, bg = p.sumiInk1 })
set(0, 'BufferInactiveIndex', { fg = p.fujiGray, bg = p.sumiInk1 })
set(0, 'BufferInactiveTarget', { fg = p.samuraiRed, bg = p.sumiInk1 })
set(0, 'BufferTabpage', { fg = p.sumiInk5, bg = p.sumiInk1 })
set(0, 'BufferTabpages', { bg = p.sumiInk1 })

-- Notify
set(0, 'NotifyERRORTitle', { fg = p.samuraiRed })
set(0, 'NotifyERRORBorder', { fg = p.winterRed })
set(0, 'NotifyWARNTitle', { fg = p.roninYellow })
set(0, 'NotifyWARNBorder', { fg = p.roninYellow })
set(0, 'NotifyINFOTitle', { fg = p.dragonBlue })
set(0, 'NotifyINFOBorder', { fg = p.waveBlue2 })
set(0, 'NotifyINFOTitle40', { fg = p.sumiInk1 })
set(0, 'NotifyINFOBody40', { fg = p.sumiInk1, bg = p.sumiInk1 })
set(0, 'NotifyINFOIcon40', { fg = p.sumiInk1 })
set(0, 'NotifyINFOBorder40', { fg = p.sumiInk0 })
set(0, 'NotifyDEBUGTitle', { fg = p.waveAqua1 })
set(0, 'NotifyDEBUGBorder', { fg = p.winterGreen })
set(0, 'NotifyTRACETitle', { fg = p.fujiGray })
set(0, 'NotifyTRACEBorder', { fg = p.sumiInk5 })

-- Neominimap
set(0, 'NeominimapErrorLine', { bg = p.samuraiRed })
set(0, 'NeominimapWarnLine', { bg = p.oniViolet })
set(0, 'NeominimapInfoLine', { bg = p.dragonBlue })
set(0, 'NeominimapHintLine', { bg = p.waveAqua1 })
set(0, 'NeominimapErrorSign', { fg = p.samuraiRed })
set(0, 'NeominimapWarnSign', { fg = p.oniViolet })
set(0, 'NeominimapInfoSign', { fg = p.dragonBlue })
set(0, 'NeominimapHintSign', { fg = p.waveAqua1 })
set(0, 'NeominimapErrorIcon', { fg = p.samuraiRed })
set(0, 'NeominimapWarnIcon', { fg = p.oniViolet })
set(0, 'NeominimapInfoIcon', { fg = p.dragonBlue })
set(0, 'NeominimapHintIcon', { fg = p.waveAqua1 })
set(0, 'NeominimapGitChangeLine', { bg = p.waveAqua1 })
set(0, 'NeominimapGitChangeIcon', { fg = p.waveAqua1 })
set(0, 'NeominimapGitChangeSign', { fg = p.waveAqua1 })
set(0, 'NeominimapGitAddLine', { bg = p.springGreen })
set(0, 'NeominimapGitAddIcon', { fg = p.springGreen })
set(0, 'NeominimapGitAddSign', { fg = p.springGreen })
set(0, 'NeominimapGitDeleteLine', { bg = p.samuraiRed })
set(0, 'NeominimapGitDeleteIcon', { fg = p.samuraiRed })
set(0, 'NeominimapGitDeleteSign', { fg = p.samuraiRed })
set(0, '_Neominimap.@constructor', { fg = p.springBlue })
set(0, '_Neominimap.@number', { fg = p.oniViolet })
set(0, '_Neominimap.@operator', { fg = p.autumnRed })
set(0, '_Neominimap.@property', { fg = p.dragonBlue })
set(0, '_Neominimap.@string', { fg = p.springGreen })
set(0, '_Neominimap.@variable', { fg = p.oldWhite })
set(0, '_Neominimap.@variable.member', { fg = p.dragonBlue })
set(0, '_Neominimap.@punctuation.delimiter', { fg = p.oldWhite })
set(0, '_Neominimap.@punctuation.bracket', { fg = p.oldWhite })
set(0, '_Neominimap.@comment', { fg = p.fujiGray })
set(0, '_Neominimap.@keyword', { fg = p.oniViolet })
set(0, '_Neominimap.@boolean', { fg = p.waveAqua1 })

-- TinyInlineDiagnostic
set(0, 'TinyInlineDiagnosticVirtualTextHint', { fg = p.waveAqua1, bg = p.winterGreen })
set(0, 'TinyInlineDiagnosticVirtualTextWarn', { fg = p.roninYellow, bg = p.winterYellow })
set(0, 'TinyInlineDiagnosticVirtualTextError', { fg = p.samuraiRed, bg = p.winterRed })
set(0, 'TinyInlineDiagnosticVirtualTextInfo', { fg = p.dragonBlue, bg = p.waveBlue1 })
set(0, 'TinyInlineDiagnosticVirtualTextBg', { bg = p.sumiInk5 })
set(0, 'TinyInlineDiagnosticVirtualTextArrow', { fg = p.sumiInk5, bg = p.sumiInk5 })
set(0, 'TinyInlineDiagnosticVirtualTextArrowNoBg', { fg = p.sumiInk5 })
set(0, 'TinyInlineDiagnosticVirtualTextErrorNoBg', { fg = p.samuraiRed })
set(0, 'TinyInlineDiagnosticVirtualTextWarnNoBg', { fg = p.roninYellow })
set(0, 'TinyInlineDiagnosticVirtualTextInfoNoBg', { fg = p.dragonBlue })
set(0, 'TinyInlineDiagnosticVirtualTextHintNoBg', { fg = p.waveAqua1 })
set(0, 'TinyInlineDiagnosticVirtualTextErrorMixError', { fg = p.samuraiRed, bg = p.winterRed })
set(0, 'TinyInlineDiagnosticVirtualTextErrorMixWarn', { fg = p.samuraiRed, bg = p.winterYellow })
set(0, 'TinyInlineDiagnosticVirtualTextErrorMixInfo', { fg = p.samuraiRed, bg = p.waveBlue1 })
set(0, 'TinyInlineDiagnosticVirtualTextErrorMixHint', { fg = p.samuraiRed, bg = p.winterGreen })
set(0, 'TinyInlineDiagnosticVirtualTextWarnMixWarn', { fg = p.roninYellow, bg = p.winterYellow })
set(0, 'TinyInlineDiagnosticVirtualTextWarnMixInfo', { fg = p.roninYellow, bg = p.waveBlue1 })
set(0, 'TinyInlineDiagnosticVirtualTextWarnMixHint', { fg = p.roninYellow, bg = p.winterGreen })
set(0, 'TinyInlineDiagnosticVirtualTextInfoMixWarn', { fg = p.dragonBlue, bg = p.winterYellow })
set(0, 'TinyInlineDiagnosticVirtualTextInfoMixInfo', { fg = p.dragonBlue, bg = p.waveBlue1 })
set(0, 'TinyInlineDiagnosticVirtualTextInfoMixHint', { fg = p.dragonBlue, bg = p.winterGreen })
set(0, 'TinyInlineDiagnosticVirtualTextHintMixInfo', { fg = p.waveAqua1, bg = p.waveBlue1 })
set(0, 'TinyInlineDiagnosticVirtualTextHintMixWarn', { fg = p.waveAqua1, bg = p.winterYellow })
set(0, 'TinyInlineDiagnosticVirtualTextHintMixError', { fg = p.waveAqua1, bg = p.winterRed })
set(0, 'TinyInlineDiagnosticVirtualTextHintMixHint', { fg = p.waveAqua1, bg = p.winterGreen })
set(0, 'TinyInlineDiagnosticVirtualTextErrorCursorLine', { fg = p.samuraiRed })
set(0, 'TinyInlineDiagnosticVirtualTextWarnCursorLine', { fg = p.roninYellow })
set(0, 'TinyInlineDiagnosticVirtualTextInfoCursorLine', { fg = p.dragonBlue })
set(0, 'TinyInlineDiagnosticVirtualTextHintCursorLine', { fg = p.waveAqua1 })
set(0, 'TinyInlineInvDiagnosticVirtualTextHint', { fg = p.winterGreen, bg = p.sumiInk5 })
set(0, 'TinyInlineInvDiagnosticVirtualTextWarn', { fg = p.winterYellow, bg = p.sumiInk5 })
set(0, 'TinyInlineInvDiagnosticVirtualTextError', { fg = p.winterRed, bg = p.sumiInk5 })
set(0, 'TinyInlineInvDiagnosticVirtualTextInfo', { fg = p.waveBlue1, bg = p.sumiInk5 })
set(0, 'TinyInlineInvDiagnosticVirtualTextHintNoBg', { fg = p.winterGreen })
set(0, 'TinyInlineInvDiagnosticVirtualTextWarnNoBg', { fg = p.winterYellow })
set(0, 'TinyInlineInvDiagnosticVirtualTextErrorNoBg', { fg = p.winterRed })
set(0, 'TinyInlineInvDiagnosticVirtualTextInfoNoBg', { fg = p.waveBlue1 })
set(0, 'TinyInlineInvDiagnosticVirtualTextHintCursorLine', { fg = p.winterGreen })
set(0, 'TinyInlineInvDiagnosticVirtualTextWarnCursorLine', { fg = p.winterYellow })
set(0, 'TinyInlineInvDiagnosticVirtualTextErrorCursorLine', { fg = p.winterRed })
set(0, 'TinyInlineInvDiagnosticVirtualTextInfoCursorLine', { fg = p.waveBlue1 })

-- SmearCursor
set(0, 'SmearCursor1', { fg = p.sumiInk5, blend = 0 })
set(0, 'SmearCursor2', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor3', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor4', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor5', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor6', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor7', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor8', { fg = p.fujiGray, blend = 0 })
set(0, 'SmearCursor9', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor10', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor11', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor12', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor13', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor14', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor15', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursor16', { fg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorHideable', { fg = p.fujiWhite, blend = 100 })
set(0, 'SmearCursorInverted1', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted2', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted3', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted4', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted5', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted6', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted7', { fg = p.sumiInk2, bg = p.fujiGray, blend = 0 })
set(0, 'SmearCursorInverted8', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted9', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted10', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted11', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted12', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted13', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted14', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted15', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })
set(0, 'SmearCursorInverted16', { fg = p.sumiInk2, bg = p.oldWhite, blend = 0 })

-- SmoothCursor
set(0, 'SmoothCursor', { fg = p.sumiInk6 })
set(0, 'SmoothCursorRed', { fg = p.samuraiRed })
set(0, 'SmoothCursorRed1', { fg = p.samuraiRed })
set(0, 'SmoothCursorRed2', { fg = p.samuraiRed })
set(0, 'SmoothCursorBlue', { fg = p.springBlue })
set(0, 'SmoothCursorBlue1', { fg = p.waveBlue2 })
set(0, 'SmoothCursorBlue2', { fg = p.waveBlue2 })
set(0, 'SmoothCursorBlue3', { fg = p.waveBlue1 })
set(0, 'SmoothCursorGreen', { fg = p.springGreen })
set(0, 'SmoothCursorYellow', { fg = p.sumiInk6 })
set(0, 'SmoothCursorYellow1', { fg = p.sumiInk6 })
set(0, 'SmoothCursorYellow2', { fg = p.sumiInk6 })
set(0, 'SmoothCursorOrange', { fg = p.sumiInk6 })
set(0, 'SmoothCursorPurple', { fg = p.oniViolet })
set(0, 'SmoothCursorAqua', { fg = p.waveAqua1 })
set(0, 'SmoothCursorScarlet1', { fg = p.samuraiRed })
set(0, 'SmoothCursorScarlet2', { fg = p.samuraiRed })

-- RainbowDelimiter / TSRainbow
set(0, 'RainbowDelimiterRed', { fg = p.samuraiRed })
set(0, 'RainbowDelimiterOrange', { fg = p.sumiInk6 })
set(0, 'RainbowDelimiterYellow', { fg = p.sumiInk6 })
set(0, 'RainbowDelimiterGreen', { fg = p.springGreen })
set(0, 'RainbowDelimiterCyan', { fg = p.waveAqua1 })
set(0, 'RainbowDelimiterBlue', { fg = p.dragonBlue })
set(0, 'RainbowDelimiterPurple', { fg = p.oniViolet })
set(0, 'TSRainbowRed', { fg = p.samuraiRed })
set(0, 'TSRainbowOrange', { fg = p.sumiInk6 })
set(0, 'TSRainbowYellow', { fg = p.sumiInk6 })
set(0, 'TSRainbowGreen', { fg = p.springGreen })
set(0, 'TSRainbowCyan', { fg = p.waveAqua1 })
set(0, 'TSRainbowBlue', { fg = p.dragonBlue })
set(0, 'TSRainbowViolet', { fg = p.oniViolet })
set(0, 'rainbowcol1', { fg = p.samuraiRed })
set(0, 'rainbowcol2', { fg = p.sumiInk6 })
set(0, 'rainbowcol3', { fg = p.sumiInk6 })
set(0, 'rainbowcol4', { fg = p.springGreen })
set(0, 'rainbowcol5', { fg = p.waveAqua1 })
set(0, 'rainbowcol6', { fg = p.dragonBlue })
set(0, 'rainbowcol7', { fg = p.oniViolet })

-- IndentBlankline
set(0, 'IndentBlanklineChar', { fg = p.sumiInk5 })
set(0, 'IndentBlanklineContextChar', { fg = p.oldWhite })
set(0, 'IndentBlanklineContextStart', { underline = true, sp = p.oldWhite })
set(0, 'IndentBlanklineIndent1', { fg = p.sumiInk6 })
set(0, 'IndentBlanklineIndent2', { fg = p.dragonBlue })
set(0, 'IndentBlanklineIndent3', { fg = p.waveAqua1 })
set(0, 'IndentBlanklineIndent4', { fg = p.springBlue })
set(0, 'IndentBlanklineIndent5', { fg = p.samuraiRed })
set(0, 'IndentBlanklineIndent6', { fg = p.springGreen })

-- DevIcon (unchanged — file icon colors are correct as-is)
set(0, 'DevIconSvg', { fg = p.sumiInk6 })
set(0, 'DevIconDb', { fg = p.sumiInk6 })
set(0, 'DevIconGitModules', { fg = p.samuraiRed })
set(0, 'DevIconPNPMFile', { fg = p.sumiInk6 })
set(0, 'DevIconTerminal', { fg = p.springGreen })
set(0, 'DevIconHyprlock', { fg = p.springBlue })
set(0, 'DevIconSh', { fg = p.sumiInk6 })
set(0, 'DevIconCp', { fg = p.waveBlue2 })
set(0, 'DevIconSway', { fg = p.sumiInk6 })
set(0, 'DevIconPng', { fg = p.samuraiRed })
set(0, 'DevIconKotlin', { fg = p.oniViolet })
set(0, 'DevIconErl', { fg = p.samuraiRed })
set(0, 'DevIconVue', { fg = p.springGreen })
set(0, 'DevIconYaml', { fg = p.samuraiRed })
set(0, 'DevIconHtml', { fg = p.samuraiRed })
set(0, 'DevIconCss', { fg = p.oniViolet })
set(0, 'DevIconDockerfile', { fg = p.dragonBlue })
set(0, 'DevIconGo', { fg = p.springBlue })
set(0, 'DevIconRs', { fg = p.sumiInk6 })
set(0, 'DevIconPy', { fg = p.sumiInk6 })
set(0, 'DevIconJs', { fg = p.sumiInk6 })
set(0, 'DevIconTs', { fg = p.waveBlue2 })
set(0, 'DevIconTsx', { fg = p.springBlue })
set(0, 'DevIconJsx', { fg = p.springBlue })
set(0, 'DevIconLua', { fg = p.springBlue })
set(0, 'DevIconJson', { fg = p.sumiInk6 })
set(0, 'DevIconMd', { fg = p.oldWhite })
set(0, 'DevIconToml', { fg = p.samuraiRed })
set(0, 'DevIconYml', { fg = p.samuraiRed })
set(0, 'DevIconZsh', { fg = p.springGreen })
set(0, 'DevIconBash', { fg = p.springGreen })
set(0, 'DevIconBashrc', { fg = p.springGreen })
set(0, 'DevIconVim', { fg = p.springGreen })
set(0, 'DevIconGitIgnore', { fg = p.samuraiRed })
set(0, 'DevIconGitLogo', { fg = p.samuraiRed })
set(0, 'DevIconPackageJson', { fg = p.samuraiRed })
set(0, 'DevIconTxt', { fg = p.springGreen })
set(0, 'DevIconCsv', { fg = p.springGreen })
set(0, 'DevIconDefault', { fg = p.samuraiRed })
set(0, 'DevIconMarkdown', { fg = p.oldWhite })
set(0, 'DevIconReadme', { fg = p.fujiWhite })
set(0, 'DevIconLock', { fg = p.oldWhite })
set(0, 'DevIconSql', { fg = p.sumiInk6 })
set(0, 'DevIconNix', { fg = p.dragonBlue })
set(0, 'DevIconSwift', { fg = p.sumiInk6 })
set(0, 'DevIconDart', { fg = p.springBlue })
set(0, 'DevIconZig', { fg = p.sumiInk6 })
set(0, 'DevIconScss', { fg = p.samuraiRed })
set(0, 'DevIconSass', { fg = p.samuraiRed })
set(0, 'DevIconPhp', { fg = p.samuraiRed })
set(0, 'DevIconRb', { fg = p.samuraiRed })
set(0, 'DevIconJava', { fg = p.samuraiRed })
set(0, 'DevIconScala', { fg = p.samuraiRed })
set(0, 'DevIconCs', { fg = p.springGreen })
set(0, 'DevIconCpp', { fg = p.waveBlue2 })
set(0, 'DevIconC', { fg = p.dragonBlue })
set(0, 'DevIconH', { fg = p.samuraiRed })
set(0, 'DevIconPdf', { fg = p.samuraiRed })
set(0, 'DevIconXlsx', { fg = p.springGreen })
set(0, 'DevIconDocx', { fg = p.springBlue })
set(0, 'DevIconPptx', { fg = p.samuraiRed })
set(0, 'DevIconArch', { fg = p.springBlue })
set(0, 'DevIconDebian', { fg = p.samuraiRed })
set(0, 'DevIconUbuntu', { fg = p.samuraiRed })
set(0, 'DevIconFedora', { fg = p.springBlue })
set(0, 'DevIconApple', { fg = p.fujiGray })
set(0, 'DevIconWindows', { fg = p.springBlue })
set(0, 'DevIconLinux', { fg = p.fujiWhite })
set(0, 'DevIconTypeScript', { fg = p.waveBlue2 })
set(0, 'DevIconElm', { fg = p.waveBlue2 })
set(0, 'DevIconSvelte', { fg = p.samuraiRed })
set(0, 'DevIconVitestConfig', { fg = p.springGreen })
set(0, 'DevIconAstro', { fg = p.samuraiRed })
set(0, 'DevIconTerraform', { fg = p.oniViolet })
set(0, 'DevIconPrisma', { fg = p.dragonBlue })
set(0, 'DevIconGradle', { fg = p.waveBlue2 })

-- ============================================================================
-- Additional (Todo, Modes, etc.)
-- ============================================================================
set(0, 'Todo', { fg = p.sumiInk2, bg = p.dragonBlue })
set(0, 'TodoFgTODO', { fg = p.dragonBlue })
set(0, 'TodoFgFIX', { fg = p.samuraiRed })
set(0, 'TodoFgWARN', { fg = p.roninYellow })
set(0, 'TodoFgNOTE', { fg = p.waveAqua1 })
set(0, 'TodoFgTEST', { fg = p.springBlue })
set(0, 'TodoFgPERF', { fg = p.springBlue })
set(0, 'TodoFgHACK', { fg = p.oniViolet })
set(0, 'TodoBgTODO', { fg = p.sumiInk2, bg = p.dragonBlue, bold = true })
set(0, 'TodoBgFIX', { fg = p.sumiInk2, bg = p.samuraiRed, bold = true })
set(0, 'TodoBgWARN', { fg = p.sumiInk2, bg = p.roninYellow, bold = true })
set(0, 'TodoBgNOTE', { fg = p.sumiInk2, bg = p.waveAqua1, bold = true })
set(0, 'TodoBgTEST', { fg = p.sumiInk2, bg = p.springBlue, bold = true })
set(0, 'TodoBgPERF', { fg = p.sumiInk2, bg = p.springBlue, bold = true })
set(0, 'TodoBgHACK', { fg = p.sumiInk2, bg = p.oniViolet, bold = true })
set(0, 'TodoSignTODO', { fg = p.dragonBlue })
set(0, 'TodoSignFIX', { fg = p.samuraiRed })
set(0, 'TodoSignWARN', { fg = p.roninYellow })
set(0, 'TodoSignNOTE', { fg = p.waveAqua1 })
set(0, 'TodoSignTEST', { fg = p.springBlue })
set(0, 'TodoSignPERF', { fg = p.springBlue })
set(0, 'TodoSignHACK', { fg = p.oniViolet })

set(0, 'ModesInsert', { bg = p.springBlue })
set(0, 'ModesVisual', { bg = p.oniViolet })
set(0, 'ModesCopy', { bg = p.waveAqua1 })
set(0, 'ModesDelete', { bg = p.samuraiRed })

set(0, 'SnacksImageMath', { fg = p.dragonBlue })
set(0, 'NavicText', { fg = p.oldWhite })
set(0, 'NavicSeparator', { fg = p.sumiInk5 })
set(0, 'FernBranchText', { fg = p.dragonBlue })
set(0, 'NoiceHiddenCursor', { nocombine = true, blend = 100 })
set(0, 'NoiceFormatProgressDone', { fg = p.oldWhite, bg = p.fujiGray })
set(0, 'RedrawDebugNormal', { reverse = true })
set(0, 'RedrawDebugClear', { bg = p.sumiInk6 })
set(0, 'RedrawDebugComposed', { bg = p.springGreen })
set(0, 'RedrawDebugRecompose', { bg = p.samuraiRed })
set(0, 'CocInlayHint', { fg = p.fujiGray, bg = p.sumiInk3 })

set(0, 'GlyphPalette0', { fg = p.sumiInk4 })
set(0, 'GlyphPalette1', { fg = p.samuraiRed })
set(0, 'GlyphPalette2', { fg = p.springGreen })
set(0, 'GlyphPalette3', { fg = p.sumiInk6 })
set(0, 'GlyphPalette4', { fg = p.dragonBlue })
set(0, 'GlyphPalette5', { fg = p.oniViolet })
set(0, 'GlyphPalette6', { fg = p.waveAqua1 })
set(0, 'GlyphPalette7', { fg = p.oldWhite })
set(0, 'GlyphPalette8', { fg = p.sumiInk5 })
set(0, 'GlyphPalette9', { fg = p.sumiInk6 })
set(0, 'GlyphPalette10', { fg = p.springGreen })
set(0, 'GlyphPalette11', { fg = p.sumiInk6 })
set(0, 'GlyphPalette12', { fg = p.dragonBlue })
set(0, 'GlyphPalette13', { fg = p.oniViolet })
set(0, 'GlyphPalette14', { fg = p.waveAqua1 })
set(0, 'GlyphPalette15', { fg = p.oldWhite })

set(0, 'typescriptParens', { fg = p.oldWhite })
