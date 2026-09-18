local M = {}

---@type async fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
M.system = vim.async.wrap(3, vim.system)

---Resumes the task on the main loop.
---
---Awaits resume in whatever context completed them, which for `vim.system` and
---`vim.uv` callbacks is a fast event context where `vim.notify` and most of
---`vim.api` raise E5560. `vim.async.checkpoint()` is not a substitute: it does
---not yield to the event loop.
---@type async fun()
local schedule = vim.async.wrap(1, vim.schedule)

---Wraps `target` so every call hops to the main loop first, but only when the
---caller is currently in a fast event context.
---
---Calling from outside a task is fine as long as the caller is not in a fast
---event context, which is where the hop would be needed but impossible.
---@generic T: table
---@param target T
---@return T
local function main_loop_proxy(target)
  local cache = {}
  return setmetatable({}, {
    __index = function(_, key)
      if not cache[key] then
        cache[key] = function(...)
          if vim.in_fast_event() then
            schedule()
          end
          return target[key](...)
        end
      end
      return cache[key]
    end,
  })
end

---Same shape as `vim.api`, but safe to call after an await.
---@type table
M.api = main_loop_proxy(vim.api)

---Same shape as `vim.fn`, but safe to call after an await.
---@type table
M.fn = main_loop_proxy(vim.fn)

---Calls `fn` on the main loop and returns its result, for everything the
---`api` and `fn` proxies do not cover, e.g. third party plugins.
---@async
---@generic R
---@param fn fun(...): R
---@return R
function M.main_loop(fn, ...)
  if vim.in_fast_event() then
    schedule()
  end
  return fn(...)
end

---@async
---@param msg string
---@param level? integer
---@param opts? table
function M.notify(msg, level, opts)
  M.main_loop(vim.notify, msg, level, opts)
end

---Only attached (child) task errors propagate to a parent, so a top-level
---fire-and-forget task drops its error unless its completion is observed.
---@param task vim.async.Task<any>
local function report_errors(task)
  task:on_complete(function(err)
    -- `close()` completes the task with "closed", which is a cancellation, not
    -- a failure.
    if err == nil or err == "closed" then
      return
    end
    -- `on_complete` may run in a fast event context.
    vim.schedule(function()
      vim.notify(tostring(err), vim.log.levels.ERROR)
    end)
  end)
end

---Turns an async function into a plain callback, usable from synchronous
---contexts such as autocmd callbacks and keymaps.
---
---Each call starts an independent task, so tasks from rapidly repeated calls
---interleave freely at their await points. Pass `exclusive` when only the
---latest call matters and concurrent tasks would race on shared state.
---@param fn async fun(...): ...
---@param opts? { exclusive?: boolean } exclusive: close the task started by the
---previous call, if it is still running, before starting a new one
---@return fun(...)
function M.wrapped(fn, opts)
  local exclusive = opts and opts.exclusive
  local prev ---@type vim.async.Task<any>?

  return function(...)
    if exclusive and prev and not prev:completed() then
      -- Cooperative: the task stops at its next await point. Work already
      -- started (e.g. a spawned process) is not aborted.
      prev:close()
    end
    prev = vim.async.run(fn, ...)
    report_errors(prev)
    -- Returns nothing on purpose: a truthy return value from an autocmd
    -- callback deletes the autocmd.
  end
end

return M
