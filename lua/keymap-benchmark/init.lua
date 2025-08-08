local M = {}

local file_path = vim.fn.stdpath "data" .. "/keymap_benchmark.json"

local function load_data()
  local file = io.open(file_path, "r")
  if not file then
    return {}
  end
  local content = file:read "*a"
  file:close()
  return vim.json.decode(content) or {}
end

local function save_data(data)
  local file = io.open(file_path, "w")
  if not file then
    return
  end
  file:write(vim.json.encode(data))
  file:close()
end

vim.api.nvim_create_autocmd("VimLeave", {
  group = vim.api.nvim_create_augroup("KeymapBenchmarkSaveData", { clear = true }),
  desc = "save keymap benchmark data",
  callback = function()
    save_data(M.data)
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  group = vim.api.nvim_create_augroup("KeymapBenchmarkLoadData", { clear = true }),
  desc = "save keymap benchmark data",
  callback = function()
    local new_data = load_data()
    if M.data then
      for key, value in pairs(M.data) do
        new_data[key] = (new_data[key] or 0) + value
      end
    end
    M.data = new_data
  end,
})

---@param lhs string
function M.record(lhs)
  if not M.data then
    M.data = {}
  end
  local mode = vim.api.nvim_get_mode().mode
  local key = mode .. ":" .. lhs
  if not M.data[key] then
    M.data[key] = 0
  end
  M.data[key] = M.data[key] + 1
end

---@param mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@param lhs string           Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---@param opts? vim.keymap.set.Opts
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  vim.validate("mode", mode, { "string", "table" })
  vim.validate("lhs", lhs, "string")
  vim.validate("rhs", rhs, { "string", "function" })
  vim.validate("opts", opts, "table", true)

  opts = vim.deepcopy(opts or {}, true)

  ---@cast mode string[]
  mode = type(mode) == "string" and { mode } or mode

  if opts.expr and opts.replace_keycodes ~= false then
    opts.replace_keycodes = true
  end

  if opts.remap == nil then
    -- default remap value is false
    opts.noremap = true
  else
    -- remaps behavior is opposite of noremap option.
    opts.noremap = not opts.remap
    opts.remap = nil ---@type boolean?
  end

  if type(rhs) == "function" then
    local rhs_fn = rhs
    opts.callback = function()
      M.record(lhs)
      return rhs_fn()
    end
    rhs = ""
  else
    opts.callback = function()
      M.record(lhs)
      return rhs
    end
    opts.expr = true
    opts.replace_keycodes = true
  end

  if opts.buffer then
    local bufnr = opts.buffer == true and 0 or opts.buffer --[[@as integer]]
    opts.buffer = nil ---@type integer?
    for _, m in ipairs(mode) do
      vim.api.nvim_buf_set_keymap(bufnr, m, lhs, rhs, opts)
    end
  else
    opts.buffer = nil
    for _, m in ipairs(mode) do
      vim.api.nvim_set_keymap(m, lhs, rhs, opts)
    end
  end
end

return M
