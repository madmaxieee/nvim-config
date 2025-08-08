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

---@param mode string
---@param lhs string
function M.record(mode, lhs)
  if not M.data then
    M.data = {}
  end
  local key = mode .. ":" .. lhs
  if not M.data[key] then
    M.data[key] = 0
  end
  M.data[key] = M.data[key] + 1
end

function M.wrap_rhs(lhs, rhs)
  return function()
    local mode = vim.api.nvim_get_mode().mode
    M.record(mode, lhs)
    if type(rhs) == "string" then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(rhs, true, true, true), mode, false)
      return
    end
    return rhs()
  end
end

return M
