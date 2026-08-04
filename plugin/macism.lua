if vim.fn.has("mac") ~= 1 or vim.fn.executable("macism") ~= 1 then
  return
end

local _ABC_KEYBOARD = "com.apple.keylayout.ABC"

local saved_method

local function get_current_input_method()
  local result = vim.system({ "macism" }, { text = true }):wait()
  return vim.trim(result.stdout)
end

local function select_input_method(method)
  vim.system({ "macism", method }):wait()
end

local group = vim.api.nvim_create_augroup("macism", {})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  once = true,
  callback = function()
    saved_method = get_current_input_method()
  end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
  group = group,
  callback = function()
    if saved_method and get_current_input_method() ~= saved_method then
      select_input_method(saved_method)
    end
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = group,
  callback = function()
    saved_method = get_current_input_method()
    if saved_method ~= _ABC_KEYBOARD then
      select_input_method(_ABC_KEYBOARD)
    end
  end,
})
