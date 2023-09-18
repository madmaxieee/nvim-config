-- disable relative line numbers in command mode
local relative_line_group = vim.api.nvim_create_augroup("RelativeLine", { clear = true })

vim.api.nvim_create_autocmd({ "CmdLineEnter" }, {
  group = relative_line_group,
  callback = function()
    vim.wo.relativenumber = false
    vim.api.nvim_command "redraw"
  end,
})

vim.api.nvim_create_autocmd({ "CmdLineLeave" }, {
  group = relative_line_group,
  callback = function()
    vim.wo.relativenumber = true
  end,
})
