local M = {}

---@type async fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
M.system = vim.async.wrap(3, vim.system)

---Only attached (child) task errors propagate to a parent, so a top-level
---fire-and-forget task drops its error unless its completion is observed.
---@param task vim.async.Task<any>
local function report_errors(task)
  task:on_complete(function(err)
    if err == nil then
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
---@param fn async fun(...): ...
---@return fun(...)
function M.wrapped(fn)
  return function(...)
    report_errors(vim.async.run(fn, ...))
    -- Returns nothing on purpose: a truthy return value from an autocmd
    -- callback deletes the autocmd.
  end
end

return M
