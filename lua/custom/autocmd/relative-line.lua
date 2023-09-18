-- disable relative line numbers in command mode
local relative_line_group = vim.api.nvim_create_augroup("RelativeLine", { clear = true })

local relative_line_enabled = false

vim.api.nvim_create_autocmd({ "CmdLineEnter" }, {
  group = relative_line_group,
  callback = function()
    relative_line_enabled = vim.wo.relativenumber
    if relative_line_enabled then
      vim.wo.relativenumber = false
      vim.api.nvim_command "redraw"
    end
  end,
})

vim.api.nvim_create_autocmd({ "CmdLineLeave" }, {
  group = relative_line_group,
  callback = function()
    if relative_line_enabled then
      vim.wo.relativenumber = true
    end
  end,
})
