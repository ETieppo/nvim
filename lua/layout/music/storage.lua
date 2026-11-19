local M = {}
local DIRECTORY_MODE = tonumber('700', 8)
local SECRET_FILE_MODE = tonumber('600', 8)
local PUBLIC_FILE_MODE = tonumber('644', 8)
local TEMPORARY_SUFFIX = '.tmp'
local JSON_DECODE_OPTIONS = { luanil = { object = true, array = true } }

---@param content string
---@return table|nil
function M.decode_json(content)
  if content == '' then return nil end
  local ok, decoded = pcall(vim.json.decode, content, JSON_DECODE_OPTIONS)
  if not ok or type(decoded) ~= 'table' then return nil end
  return decoded
end

---@param path string
---@return table|nil
function M.read_json(path)
  local file = io.open(path, 'r')
  if not file then return nil end
  local content = file:read '*a'
  file:close()
  return M.decode_json(content)
end

---@param path string
---@param value table
---@param is_secret boolean
---@return boolean
function M.write_json(path, value, is_secret)
  local mode = is_secret and SECRET_FILE_MODE or PUBLIC_FILE_MODE
  local temporary_path = path .. TEMPORARY_SUFFIX
  vim.fn.mkdir(vim.fs.dirname(path), 'p', DIRECTORY_MODE)

  local descriptor = vim.uv.fs_open(temporary_path, 'w', mode)
  if not descriptor then return false end
  vim.uv.fs_chmod(temporary_path, mode)
  local written = vim.uv.fs_write(descriptor, vim.json.encode(value))
  vim.uv.fs_close(descriptor)
  if not written then return false end

  return vim.uv.fs_rename(temporary_path, path) == true
end

---@param path string
function M.remove(path) vim.uv.fs_unlink(path) end

return M
