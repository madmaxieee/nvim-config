-- auto reload files when changed outside of neovim
vim.api.nvim_create_autocmd("FocusGained", {
  group = vim.api.nvim_create_augroup("AutoReload", {}),
  desc = "Auto reload files when changed outside of neovim",
  callback = function()
    vim.cmd("checktime")
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankHighlight", {}),
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.hl_op({ higroup = "Visual", timeout = 200 })
  end,
})

-- restore cursor position
vim.api.nvim_create_autocmd("BufRead", {
  group = vim.api.nvim_create_augroup("RestoreCursorPos", {}),
  desc = "Restore cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd('normal! g`"')
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ResizeWindows", {}),
  desc = "Resize windows when vim is resized",
  command = "wincmd =",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("FileChangeNotify", {}),
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
  desc = "Notify when a file is changed externally",
})
