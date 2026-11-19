local M = {}

---@return thread|nil
function M.current_coroutine()
  local co, is_main = coroutine.running()
  return not is_main and co or nil
end

---@async
---@generic T
---@param open fun(resolve: fun(value?: T))
---@return T|nil
function M.await(open)
  local co = coroutine.running()
  local settled = false

  open(function(value)
    if settled then return end
    settled = true
    vim.schedule(function()
      local ok, err = coroutine.resume(co, value)
      if not ok then vim.notify.error(debug.traceback(co, tostring(err))) end
    end)
  end)

  return coroutine.yield()
end

---@async
---@param milliseconds integer
function M.sleep(milliseconds)
  M.await(function(resolve) vim.defer_fn(resolve, milliseconds) end)
end

---@generic T
---@param fn async fun(...): T
---@return async fun(...): T
function M.single_flight(fn)
  local is_running = false
  ---@type fun(value: any)[]
  local waiting_resolvers = {}

  return function(...)
    if is_running then
      return M.await(
        function(resolve) waiting_resolvers[#waiting_resolvers + 1] = resolve end
      )
    end

    is_running = true
    local ok, result = pcall(fn, ...)
    is_running = false

    local resolvers = waiting_resolvers
    waiting_resolvers = {}
    for _, resolve in ipairs(resolvers) do
      resolve(ok and result or nil)
    end
    if not ok then error(result, 0) end
    return result
  end
end

---@param fn async fun(...)
---@param ... any
function M.run(fn, ...)
  local co = coroutine.create(fn)
  local ok, err = coroutine.resume(co, ...)
  if not ok then vim.notify.error(debug.traceback(co, tostring(err))) end
end

return M
