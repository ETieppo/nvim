local M = {}

---@enum HttpMethodEnum
M.HttpMethodEnum = {
  get = 'GET',
  post = 'POST',
  put = 'PUT',
  delete = 'DELETE',
}

---@enum WebSocketOpcodeEnum
M.WebSocketOpcodeEnum = {
  continuation = 0x0,
  text = 0x1,
  binary = 0x2,
  close = 0x8,
  ping = 0x9,
  pong = 0xA,
}

return M
