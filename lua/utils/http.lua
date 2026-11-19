local HttpResponseDto = require('utils.dtos').HttpResponseDto

---@class HttpRequestProps
---@field method HttpMethodEnum
---@field url string
---@field query? table<string, string|integer>
---@field headers? table<string, string>
---@field json_body? table
---@field form_body? table<string, string>
---@field timeout_seconds? integer

local M = {}
local CURL_COMMAND = { 'curl', '--config', '-' }
local WRITE_OUT_FORMAT = '\\n%{http_code} %header{retry-after}'
local STATUS_LINE_PATTERN = '^(%d+) ?(%d*)'
local LAST_LINE_PATTERN = '\n[^\n]*$'
local CONFIG_ESCAPE_PATTERN = '[\\"]'
local DEFAULT_TIMEOUT_SECONDS = 20
local CONNECT_TIMEOUT_SECONDS = 5
local URI_ENCODING_RFC = 'rfc2396'
---@type table<integer, boolean>
local NETWORK_EXIT_CODES = {
  [5] = true,
  [6] = true,
  [7] = true,
  [28] = true,
  [35] = true,
  [52] = true,
  [56] = true,
}

---@param value string
---@return string
local function quote_config_value(value)
  local escaped = value:gsub(CONFIG_ESCAPE_PATTERN, '\\%0'):gsub('\n', '\\n')
  return '"' .. escaped .. '"'
end

---@param query table<string, string|integer>|nil
---@return string
function M.encode_query(query)
  if not query then return '' end

  local parameters = {}
  for key, value in pairs(query) do
    parameters[#parameters + 1] = vim.uri.encode(key, URI_ENCODING_RFC)
      .. '='
      .. vim.uri.encode(tostring(value), URI_ENCODING_RFC)
  end
  table.sort(parameters)
  return table.concat(parameters, '&')
end

---@param request HttpRequestProps
---@return string
local function build_url(request)
  local query = M.encode_query(request.query)
  if query == '' then return request.url end
  local separator = request.url:find('?', 1, true) and '&' or '?'
  return request.url .. separator .. query
end

---@param lines string[]
---@param request HttpRequestProps
local function append_body(lines, request)
  if request.json_body then
    lines[#lines + 1] = 'header = "Content-Type: application/json"'
    lines[#lines + 1] = 'data-raw = '
      .. quote_config_value(vim.json.encode(request.json_body))
    return
  end

  for key, value in pairs(request.form_body or {}) do
    lines[#lines + 1] = 'data-urlencode = '
      .. quote_config_value(key .. '=' .. value)
  end
end

---@param request HttpRequestProps
---@return string
local function build_config(request)
  local lines = {
    'silent',
    'show-error',
    'url = ' .. quote_config_value(build_url(request)),
    'request = ' .. quote_config_value(request.method),
    'max-time = ' .. (request.timeout_seconds or DEFAULT_TIMEOUT_SECONDS),
    'connect-timeout = ' .. CONNECT_TIMEOUT_SECONDS,
    'write-out = "' .. WRITE_OUT_FORMAT .. '"',
  }

  for name, value in pairs(request.headers or {}) do
    lines[#lines + 1] = 'header = ' .. quote_config_value(name .. ': ' .. value)
  end
  append_body(lines, request)
  return table.concat(lines, '\n')
end

---@param result vim.SystemCompleted
---@return HttpResponseDto
local function parse_result(result)
  if result.code ~= 0 then
    return HttpResponseDto.failure(
      NETWORK_EXIT_CODES[result.code] == true,
      vim.trim(result.stderr or '')
    )
  end

  local stdout = result.stdout or ''
  local separator = stdout:find(LAST_LINE_PATTERN)
  local body = separator and stdout:sub(1, separator - 1) or ''
  local status, retry_after =
    stdout:sub((separator or 0) + 1):match(STATUS_LINE_PATTERN)

  return HttpResponseDto.new(tonumber(status) or 0, body, tonumber(retry_after))
end

---@param request HttpRequestProps
---@param on_response fun(response: HttpResponseDto)
function M.request(request, on_response)
  local ok, error_message = pcall(
    vim.system,
    CURL_COMMAND,
    { stdin = build_config(request), text = true },
    vim.schedule_wrap(function(result) on_response(parse_result(result)) end)
  )
  if not ok then
    on_response(HttpResponseDto.failure(false, tostring(error_message)))
  end
end

return M
