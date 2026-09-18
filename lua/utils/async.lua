local M = {}

---@type async fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
M.system = vim.async.wrap(3, vim.system)

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
