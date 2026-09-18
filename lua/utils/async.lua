local M = {}

---@type async fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
M.system = vim.async.wrap(3, vim.system)

---@param fn fun(...): ...
function M.wrapped(fn)
  return function()
    vim.async.run(fn)
  end
end

return M
