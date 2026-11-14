local enums = require 'useless.wpm.enums'

local M = {}
local KeystrokeKindEnum = enums.KeystrokeKindEnum
local FIRST_PRINTABLE_BYTE = 0x20
local DELETE_BYTE = 0x7f
local FIRST_UTF8_LEAD_BYTE = 0xc2
local FIRST_THREE_BYTE_LEAD_BYTE = 0xe0
local FIRST_FOUR_BYTE_LEAD_BYTE = 0xf0
local LAST_UTF8_LEAD_BYTE = 0xf4
local KEYWORD_RUN_PATTERN = '[%w_\128-\255]+%s*$'
local SYMBOL_RUN_PATTERN = '[^%w_%s\128-\255]+%s*$'
local WHITESPACE_RUN_PATTERN = '%s+$'
local LEADING_WHITESPACE_PATTERN = '^%s+'
---@type table<string, KeystrokeKindEnum>
local KEYSTROKE_KIND_BY_KEY_NAME = {
  ['<CR>'] = KeystrokeKindEnum.character,
  ['<BS>'] = KeystrokeKindEnum.deletion,
  ['<C-H>'] = KeystrokeKindEnum.deletion,
  ['<C-W>'] = KeystrokeKindEnum.word_deletion,
  ['<C-U>'] = KeystrokeKindEnum.line_deletion,
}

---@param lead_byte integer
---@return integer
local function get_utf8_sequence_length(lead_byte)
  if lead_byte < FIRST_THREE_BYTE_LEAD_BYTE then return 2 end
  if lead_byte < FIRST_FOUR_BYTE_LEAD_BYTE then return 3 end
  return 4
end

---@param typed string
---@return boolean
local function is_printable_character(typed)
  local lead_byte = typed:byte(1)
  if #typed == 1 then
    return lead_byte >= FIRST_PRINTABLE_BYTE and lead_byte < DELETE_BYTE
  end
  return lead_byte >= FIRST_UTF8_LEAD_BYTE
    and lead_byte <= LAST_UTF8_LEAD_BYTE
    and #typed == get_utf8_sequence_length(lead_byte)
end

---@param text string
---@return string
local function match_word_before_cursor(text)
  return text:match(KEYWORD_RUN_PATTERN)
    or text:match(SYMBOL_RUN_PATTERN)
    or text:match(WHITESPACE_RUN_PATTERN)
    or ''
end

---@param typed string
---@return KeystrokeKindEnum
function M.classify(typed)
  if is_printable_character(typed) then return KeystrokeKindEnum.character end
  return KEYSTROKE_KIND_BY_KEY_NAME[vim.fn.keytrans(typed)]
    or KeystrokeKindEnum.ignored
end

---@param kind KeystrokeKindEnum
---@return integer
function M.count_deleted_characters(kind)
  if kind == KeystrokeKindEnum.deletion then return 1 end

  local column = vim.api.nvim_win_get_cursor(0)[2]
  local text_before_cursor = vim.api.nvim_get_current_line():sub(1, column)
  if text_before_cursor == '' then return 1 end

  if kind == KeystrokeKindEnum.line_deletion then
    return vim.fn.strchars(
      (text_before_cursor:gsub(LEADING_WHITESPACE_PATTERN, ''))
    )
  end
  return vim.fn.strchars(match_word_before_cursor(text_before_cursor))
end

return M
