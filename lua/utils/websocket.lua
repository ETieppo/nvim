local bit = require 'bit'
local uv_handle = require 'utils.uv_handle'
local WebSocketOpcodeEnum = require('utils.enums').WebSocketOpcodeEnum

---@class WebSocketHandlersProps
---@field on_open fun()
---@field on_text fun(text: string)
---@field on_close fun(reason: string)

---@class WebSocketConnectionProps
---@field tcp uv.uv_tcp_t
---@field handlers WebSocketHandlersProps
---@field buffer string
---@field fragments string[]
---@field is_handshake_done boolean
---@field is_closed boolean

---@class WebSocketFrameProps
---@field opcode WebSocketOpcodeEnum
---@field is_final boolean
---@field payload string

local M = {}
local HANDSHAKE_TERMINATOR = '\r\n\r\n'
local SWITCHING_PROTOCOLS_PATTERN = '^HTTP/1%.1 101'
local HANDSHAKE_KEY_BYTES = 16
local MASK_KEY_BYTES = 4
local FINAL_FRAME_BIT = 0x80
local MASKED_PAYLOAD_BIT = 0x80
local OPCODE_BITS = 0x0F
local PAYLOAD_LENGTH_BITS = 0x7F
local BYTE_BITS = 0xFF
local MAX_SHORT_PAYLOAD_LENGTH = 125
local MAX_MEDIUM_PAYLOAD_LENGTH = 0xFFFF
local MEDIUM_PAYLOAD_LENGTH_MARKER = 126
local LONG_PAYLOAD_LENGTH_MARKER = 127
local MEDIUM_LENGTH_HEADER_BYTES = 4
local LONG_LENGTH_HEADER_BYTES = 10
local BASE_HEADER_BYTES = 2

---@param payload string
---@param mask_key string
---@return string
local function apply_mask(payload, mask_key)
  local masked = {}
  for index = 1, #payload do
    masked[index] = string.char(
      bit.bxor(
        payload:byte(index),
        mask_key:byte((index - 1) % MASK_KEY_BYTES + 1)
      )
    )
  end
  return table.concat(masked)
end

---@param length integer
---@return string
local function encode_payload_length(length)
  if length <= MAX_SHORT_PAYLOAD_LENGTH then
    return string.char(bit.bor(MASKED_PAYLOAD_BIT, length))
  end

  if length <= MAX_MEDIUM_PAYLOAD_LENGTH then
    return string.char(
      bit.bor(MASKED_PAYLOAD_BIT, MEDIUM_PAYLOAD_LENGTH_MARKER),
      bit.rshift(length, 8),
      bit.band(length, BYTE_BITS)
    )
  end

  return string.char(
    bit.bor(MASKED_PAYLOAD_BIT, LONG_PAYLOAD_LENGTH_MARKER),
    0,
    0,
    0,
    0,
    bit.band(bit.rshift(length, 24), BYTE_BITS),
    bit.band(bit.rshift(length, 16), BYTE_BITS),
    bit.band(bit.rshift(length, 8), BYTE_BITS),
    bit.band(length, BYTE_BITS)
  )
end

---@param opcode WebSocketOpcodeEnum
---@param payload string
---@return string
local function encode_frame(opcode, payload)
  local mask_key = assert(vim.uv.random(MASK_KEY_BYTES))
  return string.char(bit.bor(FINAL_FRAME_BIT, opcode))
    .. encode_payload_length(#payload)
    .. mask_key
    .. apply_mask(payload, mask_key)
end

---@param buffer string
---@return integer|nil payload_length
---@return integer|nil header_length
local function decode_payload_length(buffer)
  local length = bit.band(buffer:byte(2), PAYLOAD_LENGTH_BITS)

  if length == MEDIUM_PAYLOAD_LENGTH_MARKER then
    if #buffer < MEDIUM_LENGTH_HEADER_BYTES then return nil, nil end
    return buffer:byte(3) * 256 + buffer:byte(4), MEDIUM_LENGTH_HEADER_BYTES
  end

  if length == LONG_PAYLOAD_LENGTH_MARKER then
    if #buffer < LONG_LENGTH_HEADER_BYTES then return nil, nil end
    local long_length = 0
    for index = 3, LONG_LENGTH_HEADER_BYTES do
      long_length = long_length * 256 + buffer:byte(index)
    end
    return long_length, LONG_LENGTH_HEADER_BYTES
  end

  return length, BASE_HEADER_BYTES
end

---@param connection WebSocketConnectionProps
---@return WebSocketFrameProps|nil
local function take_frame(connection)
  local buffer = connection.buffer
  if #buffer < BASE_HEADER_BYTES then return nil end

  local payload_length, header_length = decode_payload_length(buffer)
  if not payload_length or not header_length then return nil end

  local first_byte, second_byte = buffer:byte(1, 2)
  local is_masked = bit.band(second_byte, MASKED_PAYLOAD_BIT) ~= 0
  local mask_length = is_masked and MASK_KEY_BYTES or 0
  local payload_start = header_length + mask_length + 1
  local payload_end = payload_start + payload_length - 1
  if #buffer < payload_end then return nil end

  local payload = buffer:sub(payload_start, payload_end)
  if is_masked then
    payload =
      apply_mask(payload, buffer:sub(header_length + 1, payload_start - 1))
  end
  connection.buffer = buffer:sub(payload_end + 1)

  return {
    opcode = bit.band(first_byte, OPCODE_BITS),
    is_final = bit.band(first_byte, FINAL_FRAME_BIT) ~= 0,
    payload = payload,
  }
end

---@param connection WebSocketConnectionProps
---@param reason string
local function close_connection(connection, reason)
  if connection.is_closed then return end
  connection.is_closed = true
  uv_handle.close(connection.tcp)
  vim.schedule(function() connection.handlers.on_close(reason) end)
end

---@param connection WebSocketConnectionProps
---@param opcode WebSocketOpcodeEnum
---@param payload string
local function write_frame(connection, opcode, payload)
  connection.tcp:write(encode_frame(opcode, payload))
end

---@param connection WebSocketConnectionProps
---@param frame WebSocketFrameProps
local function handle_frame(connection, frame)
  if
    frame.opcode == WebSocketOpcodeEnum.text
    or frame.opcode == WebSocketOpcodeEnum.continuation
  then
    connection.fragments[#connection.fragments + 1] = frame.payload
    if not frame.is_final then return end

    local message = table.concat(connection.fragments)
    connection.fragments = {}
    vim.schedule(function() connection.handlers.on_text(message) end)
  elseif frame.opcode == WebSocketOpcodeEnum.ping then
    write_frame(connection, WebSocketOpcodeEnum.pong, frame.payload)
  elseif frame.opcode == WebSocketOpcodeEnum.close then
    write_frame(connection, WebSocketOpcodeEnum.close, '')
    close_connection(connection, 'closed by server')
  end
end

---@param connection WebSocketConnectionProps
local function process_frames(connection)
  local frame = take_frame(connection)
  while frame and not connection.is_closed do
    handle_frame(connection, frame)
    frame = take_frame(connection)
  end
end

---@param connection WebSocketConnectionProps
---@return boolean
local function complete_handshake(connection)
  local terminator_start = connection.buffer:find(HANDSHAKE_TERMINATOR, 1, true)
  if not terminator_start then return false end

  if not connection.buffer:find(SWITCHING_PROTOCOLS_PATTERN) then
    close_connection(connection, 'handshake rejected')
    return false
  end

  connection.buffer =
    connection.buffer:sub(terminator_start + #HANDSHAKE_TERMINATOR)
  connection.is_handshake_done = true
  vim.schedule(connection.handlers.on_open)
  return true
end

---@param connection WebSocketConnectionProps
---@param chunk string
local function receive(connection, chunk)
  connection.buffer = connection.buffer .. chunk
  if
    not connection.is_handshake_done and not complete_handshake(connection)
  then
    return
  end
  process_frames(connection)
end

---@param host string
---@param port integer
---@return string
local function build_handshake(host, port)
  return table.concat({
    'GET / HTTP/1.1',
    ('Host: %s:%d'):format(host, port),
    'Upgrade: websocket',
    'Connection: Upgrade',
    'Sec-WebSocket-Key: '
      .. vim.base64.encode(assert(vim.uv.random(HANDSHAKE_KEY_BYTES))),
    'Sec-WebSocket-Version: 13',
    '',
    '',
  }, '\r\n')
end

---@param host string
---@param port integer
---@param handlers WebSocketHandlersProps
---@return WebSocketConnectionProps
function M.connect(host, port, handlers)
  ---@type WebSocketConnectionProps
  local connection = {
    tcp = assert(vim.uv.new_tcp()),
    handlers = handlers,
    buffer = '',
    fragments = {},
    is_handshake_done = false,
    is_closed = false,
  }

  connection.tcp:connect(host, port, function(connect_error)
    if connect_error then return close_connection(connection, connect_error) end

    connection.tcp:read_start(function(read_error, chunk)
      if read_error then return close_connection(connection, read_error) end
      if not chunk then
        return close_connection(connection, 'connection closed')
      end
      receive(connection, chunk)
    end)
    connection.tcp:write(build_handshake(host, port))
  end)

  return connection
end

---@param connection WebSocketConnectionProps
---@return boolean
function M.is_open(connection)
  return connection.is_handshake_done and not connection.is_closed
end

---@param connection WebSocketConnectionProps
---@param text string
---@return boolean
function M.send_text(connection, text)
  if not M.is_open(connection) then return false end
  write_frame(connection, WebSocketOpcodeEnum.text, text)
  return true
end

---@param connection WebSocketConnectionProps
function M.close(connection)
  if connection.is_closed then return end
  if connection.is_handshake_done then
    write_frame(connection, WebSocketOpcodeEnum.close, '')
  end
  close_connection(connection, 'closed by client')
end

return M
