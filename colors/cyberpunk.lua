-- cyberpunk.lua

vim.cmd("hi clear")
vim.o.termguicolors = true
vim.g.colors_name = "cyberpunk"

local p = {

    -- Bg Shades
    sumiInk0 = "#0c0c10",
    sumiInk1 = "#101116",
    sumiInk2 = "#161620",
    sumiInk3 = "#1c1c28",
    sumiInk4 = "#2a2a38",
    sumiInk5 = "#303040",
    sumiInk6 = "#c7c7c7",

    waveBlue1 = "#1a1a30",
    waveBlue2 = "#2a2a50",

    winterGreen = "#1a3a25",
    winterYellow = "#3a3920",
    winterRed = "#3a1520",
    winterBlue = "#1a1a30",

    autumnGreen = "#64d98c",
    autumnRed = "#ea3355",
    autumnYellow = "#faf968",

    samuraiRed = "#ea3355",
    roninYellow = "#faf968",
    waveAqua1 = "#59c2c6",
    dragonBlue = "#6a71f6",

    oldWhite = "#c7c7c7",
    fujiWhite = "#ffffff",
    fujiGray = "#686868",

    oniViolet = "#ba3ec1",
    crystalBlue = "#6a71f6",
    springBlue = "#306fb1",

    springGreen = "#64d98c",
    carpYellow = "#faf968",

    sakuraPink = "#ed776d",
    waveRed = "#ea3355",

    katanaGray = "#505060",
}

local set = vim.api.nvim_set_hl

-- 🔥 UI base
set(0, "Normal", { fg = p.oldWhite, bg = p.sumiInk1 })
set(0, "NormalFloat", { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, "CursorLine", { bg = p.sumiInk2 })
set(0, "LineNr", { fg = p.katanaGray })
set(0, "CursorLineNr", { fg = p.waveRed })

-- 🔥 Syntax
set(0, "Comment", { fg = p.fujiGray, italic = true })
set(0, "Keyword", { fg = p.waveRed })
set(0, "Identifier", { fg = p.oldWhite })
set(0, "Function", { fg = p.springGreen })
set(0, "String", { fg = p.springGreen })
set(0, "Number", { fg = p.oniViolet })
set(0, "Type", { fg = p.waveAqua1 })
set(0, "Operator", { fg = p.waveRed })

-- 🔥 Diagnostics
set(0, "DiagnosticError", { fg = p.samuraiRed })
set(0, "DiagnosticWarn", { fg = p.roninYellow })
set(0, "DiagnosticInfo", { fg = p.dragonBlue })
set(0, "DiagnosticHint", { fg = p.waveAqua1 })

-- 🔥 Git
set(0, "DiffAdd", { bg = p.winterGreen })
set(0, "DiffDelete", { bg = p.winterRed })
set(0, "DiffChange", { bg = p.winterYellow })

-- 🔥 Visual
set(0, "Visual", { bg = "#ea3355" })

-- 🔥 Popup / menu
set(0, "Pmenu", { fg = p.oldWhite, bg = p.sumiInk2 })
set(0, "PmenuSel", { bg = p.sumiInk4 })

-- 🔥 Statusline
set(0, "StatusLine", { fg = p.oldWhite, bg = p.sumiInk3 })
set(0, "StatusLineNC", { fg = p.katanaGray, bg = p.sumiInk2 })

-- 🔥 Vert split
set(0, "VertSplit", { fg = p.sumiInk4 })

-- 🔥 Search
set(0, "Search", { bg = p.waveRed, fg = p.sumiInk1 })
set(0, "IncSearch", { bg = p.autumnYellow, fg = p.sumiInk1 })
