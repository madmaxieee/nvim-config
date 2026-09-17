local M = {}

---@type async fun(cmd: string[], opts?: vim.SystemOpts): vim.SystemCompleted
M.system = vim.async.wrap(3, vim.system)

return M
