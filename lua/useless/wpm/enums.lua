local M = {}

---@enum KeystrokeKindEnum
M.KeystrokeKindEnum = {
  character = 'character',
  deletion = 'deletion',
  word_deletion = 'word_deletion',
  line_deletion = 'line_deletion',
  ignored = 'ignored',
}

return M
