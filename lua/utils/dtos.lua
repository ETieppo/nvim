---@class HttpResponseDto
---@field status integer
---@field body string
---@field retry_after_seconds integer|nil
---@field is_network_error boolean
---@field error_message string|nil

local M = {}

M.HttpResponseDto = {}

---@param status integer
---@param body string
---@param retry_after_seconds integer|nil
---@return HttpResponseDto
function M.HttpResponseDto.new(status, body, retry_after_seconds)
  return {
    status = status,
    body = body,
    retry_after_seconds = retry_after_seconds,
    is_network_error = false,
    error_message = nil,
  }
end

---@param is_network_error boolean
---@param error_message string
---@return HttpResponseDto
function M.HttpResponseDto.failure(is_network_error, error_message)
  return {
    status = 0,
    body = '',
    retry_after_seconds = nil,
    is_network_error = is_network_error,
    error_message = error_message,
  }
end

---@param response HttpResponseDto
---@return boolean
function M.HttpResponseDto.is_success(response)
  return response.status >= 200 and response.status < 300
end

return M
