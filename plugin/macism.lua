if vim.fn.has("mac") ~= 1 or vim.fn.executable("macism") ~= 1 then
  return
end

local async_utils = require("utils.async")

local _ABC_KEYBOARD = "com.apple.keylayout.ABC"

local saved_method

---@async
local function get_current_input_method()
  local result = async_utils.system({ "macism" }, { text = true })
  return vim.trim(result.stdout)
end

---@async
local function select_input_method(method)
  async_utils.system({ "macism", method })
end

local group = vim.api.nvim_create_augroup("macism", {})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = async_utils.wrapped(function()
    saved_method = get_current_input_method()
  end),
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = async_utils.wrapped(function()
    if saved_method and get_current_input_method() ~= saved_method then
      select_input_method(saved_method)
    end
  end),
})

vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = group,
  callback = async_utils.wrapped(function()
    saved_method = get_current_input_method()
    if saved_method ~= _ABC_KEYBOARD then
      select_input_method(_ABC_KEYBOARD)
    end
  end),
})
