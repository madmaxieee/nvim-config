-- auto reload files when changed outside of neovim
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  desc = "Auto reload files when changed outside of neovim",
  callback = function()
    vim.cmd "checktime"
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank { higroup = "Visual", timeout = 200 }
  end,
})

-- restore cursor position
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("RestoreCursorPos", { clear = true }),
  desc = "Restore cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd 'normal! g`"'
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ResizeWindows", { clear = true }),
  desc = "Resize windows when vim is resized",
  command = "wincmd =",
})
